--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quest3Map = workspace.Quest3

local Quest3Sound = SoundService.Quest3 ::Sound
local WhiteSound = SoundService.Whistle ::Sound

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questsDuration = require(SettingsFolder.QuestDuration)
local questImages = require(SettingsFolder.QuestImages)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable

return function()
	Quest3Sound.Volume = 0
	Quest3Sound:Play()
	for i = 0, 0.5, 0.02 do
		task.wait(0.01)
		Quest3Sound.Volume = i
	end

	print("Starting Quest 3...")
	--// wait for transition on the client
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.CameraTransition:FireClient(player, Quest3Map, transitionTime.Quest3, questMessages.Quest3, questImages.Quest3)
	end

	-- Wait for transition to complete
	task.wait(transitionTime.Quest3)

	local teamSpawns = Quest3Map.TeamSpawns
	local teamBalls = Quest3Map.TeamBalls
	local teamStations = Quest3Map.Stations

	for i, team in pairs(teamsTable) do
		-- Skip eliminated teams
		if team.isEliminated then
			continue
		end

		-- Spawn players in their team's spawn area
		local spawnPart = teamSpawns:FindFirstChild("Spawn" .. i)
		if spawnPart then
			-- Spawn each team member
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					-- Load character
					memberObj.player:LoadCharacter()

					-- Wait for character to load
					repeat task.wait() until memberObj.player.Character and 
						memberObj.player.Character:FindFirstChild("HumanoidRootPart") and
						memberObj.player.Character:FindFirstChild("Humanoid")

					-- Position at spawn with random offset
					local randomX = math.random(-5, 5)
					local randomZ = math.random(-5, 5)
					
					if memberObj.player.Character then
						memberObj.player.Character:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(randomX, 3, randomZ)))
					end
				end
			end
		end

		-- Set up ball detection for this team
		local teamBall = teamBalls:FindFirstChild("Team" .. i .. "Ball")
		if teamBall then
			local hasReachedStation2 = false

			-- Get stations
			local parentStatin = teamStations:FindFirstChild("Team" .. i .. "Station")
			local station1 = parentStatin:FindFirstChild("Team" .. i .. "Station1")
			local station2 = parentStatin:FindFirstChild("Team" .. i .. "Station2")

			if station1 and station2 then
				-- Set up station 2 detection
				local touchPart2 = station2:FindFirstChild("Touch")
				if touchPart2 then
					touchPart2.Touched:Connect(function(hit)
						if hit == teamBall and not hasReachedStation2 then
							hasReachedStation2 = true
							-- Light up station 2
							local greenLight = station2:FindFirstChild("GreenLight")
							if greenLight then
								greenLight.Transparency = 0
							end
							local redLight = station2:FindFirstChild("RedLight")
							if redLight then
								redLight.Transparency = 1
							end
							print(string.format("Team %s reached Station 2!", team.name))
						end
					end)
				end

				-- Set up station 1 detection for return
				local touchPart1 = station1:FindFirstChild("Touch")
				if touchPart1 then
					touchPart1.Touched:Connect(function(hit)
						if hit == teamBall and hasReachedStation2 and not team.questData.quest3Finished then
							-- Complete the quest for this team
							team.questData.quest3Finished = true
							team.questData.quest3FinishTime = os.time()

							-- Light up station 1
							local greenLight = station1:FindFirstChild("GreenLight")
							if greenLight then
								greenLight.Transparency = 0
							end
							local redLight = station1:FindFirstChild("RedLight")
							if redLight then
								redLight.Transparency = 1
							end

							print(string.format("Team %s has completed Quest 3!", team.name))
						end
					end)
				end
			end
		end
	end

	-- Wait for two teams to finish or timeout
	local function getFinishedTeamsCount()
		local count = 0
		for _, team in pairs(teamsTable) do
			if team.questData.quest3Finished then
				count += 1
			end
		end
		return count
	end

	-- Wait for teams to finish (with timeout)
	local startTime = os.time()
	WhiteSound:Play()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, startTime + questsDuration.Quest3)
	end
	while getFinishedTeamsCount() < 2 do
		if (os.time() - startTime) > questsDuration.Quest3 then
			break
		elseif (#teamsTable == 1 and getFinishedTeamsCount() == 1) then
			break
		end

		task.wait(1)
	end

	-- Sort teams by finish time
	local sortedTeams = {}
	for _, team in pairs(teamsTable) do
		if not team.isEliminated then
			table.insert(sortedTeams, team)
		end
	end
	table.sort(sortedTeams, function(a, b)
		-- If neither finished, maintain original order
		if not a.questData.quest3FinishTime and not b.questData.quest3FinishTime then
			return false
		end
		-- If one didn't finish, the other is better
		if not a.questData.quest3FinishTime then return false end
		if not b.questData.quest3FinishTime then return true end
		-- Compare finish times
		return a.questData.quest3FinishTime < b.questData.quest3FinishTime
	end)

	-- Eliminate team that didn't finish in top 2
	Quest3Sound:Stop()
	WhiteSound:Play()
	local currentTime = os.time()
	for i, team in ipairs(sortedTeams) do
		-- Despawn all team members
		for _, memberId in ipairs(team.members) do
			local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
			if memberObj then
				memberObj:Despawn()
			end
		end

		if i > 2 then -- Eliminate team that didn't finish in top 2
			team.isEliminated = true
			team.eliminationTime = currentTime

			-- Mark eliminated players
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					memberObj.isEliminated = true
					memberObj.eliminationTime = currentTime
					respawnToObby(memberObj.player)
				end
			end

			print(string.format("Team %s has been eliminated!", team.name))
		else
			print(string.format("Team %s advances!", team.name))
		end
	end

	--Clear timer going on.
	ReplicatedStorage.Remotes.StartTopTimer:FireAllClients(0)
end