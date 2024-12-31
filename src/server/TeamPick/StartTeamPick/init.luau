--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questMessages = require(SettingsFolder.QuestMessages)

local TeamPick = SoundService.TeamPick ::Sound

--Maps
local TeamPickMap = workspace.TeamPick

--Modules
local spawnPlayersTeamPick = require(script.SpawnPlayersTeamPick)
local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable

--Main Function
return function()
	TeamPick.Volume = 0
	TeamPick:Play()
	for i = 0, 0.5, 0.02 do
		task.wait()
		TeamPick.Volume = i
	end

	print("Starting Team Pick...")
	spawnPlayersTeamPick()
	-- Fire camera transition to all players
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.CameraTransition:FireClient(player, TeamPickMap, transitionTime.TeamPick, questMessages.TeamPick)
	end

	-- Wait for transition to complete
	task.wait(transitionTime.TeamPick)

	-- Get all non-team players
	local function getNonTeamPlayers()
		local available = {}
		for _, plrInfo in pairs(playersTable) do
			if not plrInfo.isEliminated and not plrInfo.team then
				table.insert(available, plrInfo)
			end
		end
		return available
	end

	-- Keep picking until everyone has a team
	while #getNonTeamPlayers() > 0 do
		for _, team in pairs(teamsTable) do
			local leaderObj = PlayerModule.GetPlayerObj(team.leader, playersTable)
			if not leaderObj then 
				continue 
			end

			-- Get available players
			local availablePlayers = getNonTeamPlayers()
			if #availablePlayers == 0 then 
				break 
			end

			-- Request leader to pick a team member with 5 second timeout
			local picked = false
			local pickedUserId = nil
			local waitTime = 20

			task.delay(waitTime, function()
				if not picked then
					-- Random pick if leader didn't choose in time
					local availablePlayers = getNonTeamPlayers()
					if #availablePlayers > 0 then
						local randomIndex = math.random(1, #availablePlayers)
						pickedUserId = availablePlayers[randomIndex].userId
						picked = true
					end
				end
			end)

			local leaderPick = Remotes.PickMember:InvokeClient(leaderObj.player, waitTime, availablePlayers)
			if leaderPick and not picked then
				pickedUserId = leaderPick
				picked = true
			end

			-- Wait for either leader pick or timeout
			while not picked do
				task.wait()
			end

			-- Validate pick and add to team
			if pickedUserId then
				local pickedPlayer = PlayerModule.GetPlayerObj(pickedUserId, playersTable)
				if pickedPlayer and not pickedPlayer.team then
					pickedPlayer.team = team.name

					table.insert(team.members, pickedUserId)

					-- Print pick information
					if picked then
						print(string.format("Leader %s picked member %s", leaderObj.name, pickedPlayer.name))
					else
						print(string.format("Random pick for Leader %s: member %s", leaderObj.name, pickedPlayer.name))
					end
				end
			end

			task.wait(1) -- Give time between picks
		end
	end

	print("Team picking finished!")
	for i = TeamPick.Volume, 0, -0.02 do
		task.wait()
		TeamPick.Volume = i
	end
	TeamPick:Stop()
	task.wait(1)
	-- Print final teams
	for teamName, team in pairs(teamsTable) do
		print(teamName .. " Team:")
		print("  Leader:", PlayerModule.GetPlayerObj(team.leader, playersTable).name)
		print("  Members:")
		for _, memberId in ipairs(team.members) do
			print("    -", PlayerModule.GetPlayerObj(memberId, playersTable).name)
		end
	end

	for _, plrInfo in pairs(playersTable) do
		plrInfo:Despawn()
	end
end