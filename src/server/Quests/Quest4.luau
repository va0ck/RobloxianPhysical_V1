--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SandBagTool = ReplicatedStorage.Tools.SandBag

local Quest4Map = workspace.Quest4

local Quest4Sound = SoundService.Quest4 ::Sound
local WhiteSound = SoundService.Whistle ::Sound

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questsDuration = require(SettingsFolder.QuestDuration)
local questImages = require(SettingsFolder.QuestImages)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby

local lastStandingTeam = require(script.Parent.Parent.Tables).lastStandingTeam
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable
local allTables = require(script.Parent.Parent.Tables)
local _A_QUESTCOUNT = require(script.Parent.Parent.Quests.A_QUESTCOUNT)

return function()
	print("Starting Quest 4...")
	_A_QUESTCOUNT.CURRENT_COUNT = 4

	-- Check if there's only one team active
	local activeTeams = {}
	for _, team in pairs(teamsTable) do
		if not team.isEliminated then
			table.insert(activeTeams, team)
		end
	end

	-- [[EyeWhisper just requested to not skip Quest4 in DMs.]]
	-- if #activeTeams == 1 then
	-- 	local getLastActiveTeam = activeTeams[1]
	-- 	lastStandingTeam.leader = getLastActiveTeam.leader
	-- 	lastStandingTeam.members = getLastActiveTeam.members
	-- 	lastStandingTeam.name = getLastActiveTeam.name
	-- 	lastStandingTeam.color = getLastActiveTeam.color
		
	-- 	lastStandingTeam.isEliminated = getLastActiveTeam.isEliminated
	-- 	lastStandingTeam.eliminationTime = getLastActiveTeam.eliminationTime
		
	-- 	lastStandingTeam.questData = getLastActiveTeam.questData
		
	-- 	print(string.format("Only one team remaining! Team %s proceeds directly to Quest 5!", lastStandingTeam.name))
	-- 	return
	-- end

	Quest4Sound:Play()

	--// wait for transition on the client
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.CameraTransition:FireClient(player, Quest4Map, transitionTime.Quest4, questMessages.Quest4, questImages.Quest4)
	end

	-- Wait for transition to complete
	task.wait(transitionTime.Quest4)

	local teamSpawns = Quest4Map.TeamSpawns
	local sandPiles = Quest4Map.SandPiles
	local scoreDisplayers = Quest4Map.ScoreDisplayers
	local bagLifters = Quest4Map.BagLifters

	local amountOfTeamsMade = 0
	local ifOneTeamOnlyThenWhatScoreMinimum = 0

	for i, team in pairs(teamsTable) do
		-- Skip eliminated teams
		if team.isEliminated then
			continue
		end

		-- Initialize team score
		team.questData.quest4Score = 0

		--If there's only one team, then sets the minimumScore needed.
		amountOfTeamsMade += 1
		if amountOfTeamsMade == 1 then
			for i = 1, #team.members, 1 do
				ifOneTeamOnlyThenWhatScoreMinimum += 4
			end
		end

		-- Spawn players spread out
		local spawnPart = teamSpawns:FindFirstChild("Spawn" .. i)
		if spawnPart then
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					-- Load character
					memberObj.player:LoadCharacter()

					-- Wait for character to load
					repeat task.wait() until memberObj.player.Character and memberObj.player.Character:FindFirstChild("HumanoidRootPart")

					-- Random spawn position
					local randomX = math.random(-5, 5)
					local randomZ = math.random(-5, 5)
					
					if memberObj.player.Character then
						memberObj.player.Character:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(randomX, 3, randomZ)))
					end
				end
			end
		end

		-- Set up sand pile prompts
		local teamSandPile = sandPiles:FindFirstChild("Team" .. i .. "Sand")
		for _, sandPile in ipairs(teamSandPile:GetChildren()) do
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Pick Up Bag"
			prompt.ObjectText = "Sand Pile"
			prompt.HoldDuration = 2
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = 10
			prompt.Parent = sandPile

			prompt.Triggered:Connect(function(player)
				-- Clear inventory first
				player.Backpack:ClearAllChildren()
				if player.Character then
					for _, tool in ipairs(player.Character:GetChildren()) do
						if tool:IsA("Tool") then
							tool:Destroy()
						end
					end
				end

				-- Give bag tool
				local newBag = SandBagTool:Clone()
				newBag.Parent = player.Backpack
			end)
		end

		-- Set up bag lifter
		local teamBagLifter = bagLifters:FindFirstChild("BagLifter" .. i)
		if teamBagLifter then
			local interactPart = teamBagLifter:FindFirstChild("InteractPart")
			local spawnSurface = teamBagLifter:FindFirstChild("SpawnSurface")
			local scoreDisplay = scoreDisplayers:FindFirstChild("TeamScore" .. i)
			local scoreText = scoreDisplay and scoreDisplay.SurfaceGui:FindFirstChild("ScoreText")

			if interactPart and spawnSurface and scoreText then
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Deposit Bag"
				prompt.ObjectText = "Bag Lifter"
				prompt.HoldDuration = 1.5
				prompt.RequiresLineOfSight = false
				prompt.MaxActivationDistance = 10
				prompt.Parent = interactPart

				scoreText.Text = "0"

				prompt.Triggered:Connect(function(player)
					-- Check if player has bag
					local hasBag = false
					local bagToRemove = nil

					-- Check backpack
					for _, tool in ipairs(player.Backpack:GetChildren()) do
						if tool.Name == "SandBag" then
							hasBag = true
							bagToRemove = tool
							break
						end
					end

					-- Check character if not found in backpack
					if not hasBag and player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool.Name == "SandBag" then
								hasBag = true
								bagToRemove = tool
								break
							end
						end
					end

					if hasBag and bagToRemove then
						-- Remove bag tool
						bagToRemove:Destroy()

						-- Increment score
						team.questData.quest4Score += 1

						-- Update score display
						scoreText.Text = tostring(team.questData.quest4Score)

						-- Clone bag on surface
						local bagAsset = ReplicatedStorage.Assets.SandBag:Clone()
						local surfaceSize = spawnSurface.Size
						local surfacePosition = spawnSurface.Position

						-- Calculate random position on surface
						local randomX = (math.random() - 0.5) * (surfaceSize.X - 1) -- Leave 0.5 units from edge
						local randomZ = (math.random() - 0.5) * (surfaceSize.Z - 1)

						bagAsset.Position = surfacePosition + Vector3.new(randomX, surfaceSize.Y/2 + 0.5, randomZ)
						bagAsset.Parent = spawnSurface
					end
				end)
			end
		end
	end

	local team1Score = -1
	local team2Score = -1

	if amountOfTeamsMade == 1 then
		print(`QUEST4 TO ONE TEAM MODE.`)
		team2Score = ifOneTeamOnlyThenWhatScoreMinimum
		local scoreDisplay = scoreDisplayers:FindFirstChild("TeamScore" .. 2)

		if scoreDisplay then
			local scoreText = scoreDisplay.SurfaceGui:FindFirstChild("ScoreText") ::TextLabel
			if scoreText then
				scoreText.Text = `{team2Score}`
			end
		end
	end

	-- Start timer for quest duration
	WhiteSound:Play()
	local startTime = os.time()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, startTime + questsDuration.Quest4)
	end
	while os.time() - startTime < questsDuration.Quest4 do
		task.wait(1)
	end

	-- Find teams with highest score
	local winningTeams = {}
	local losingTeams = {}

	local team1Object = {} :: allTables.teamsTable
	local team2Object = {} :: allTables.teamsTable

	--Set Teams
	for teamIndex, team in ipairs(teamsTable) do
		if not team.isEliminated then
			if teamIndex == 1 then
				team1Object = team
			elseif teamIndex == 2 then
				team2Object = team
			end
		end
	end
	
	if team1Object and team1Object.questData and team1Object.questData.quest4Score then
		team1Score = team1Object.questData.quest4Score
	end
	if team2Object and team2Object.questData and team2Object.questData.quest4Score then
		team2Score = team2Object.questData.quest4Score
	end

	if amountOfTeamsMade == 1 then
		--If one team, then they have to get to that score.
		if team1Score >= team2Score then
			table.insert(winningTeams, team1Object)

			if team2Object then
				table.insert(losingTeams, team2Object)
			end
		end
	else
		--Regular mode TeamVersusTeam.
		if team1Score > team2Score then
			table.insert(winningTeams, team1Object)
			table.insert(losingTeams, team2Object)
		elseif team1Score < team2Score then
			table.insert(losingTeams, team1Object)
			table.insert(winningTeams, team2Object)
		else
			--IF TIED, CHOOSE RANDOM.
			local mathRandom = math.random(1,2)
			if mathRandom == 1 then
				table.insert(winningTeams, team1Object)
				table.insert(losingTeams, team2Object)
			else
				table.insert(losingTeams, team1Object)
				table.insert(winningTeams, team2Object)
			end
		end
	end

	-- Eliminate teams with lowest score
	Quest4Sound:Stop()
	WhiteSound:Play()
	local currentTime = os.time()
	for _, team in ipairs(losingTeams) do
		if team and team.members then
			team.isEliminated = true
			team.eliminationTime = currentTime

			-- Eliminate and despawn all team members
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					memberObj:Despawn()
					memberObj.isEliminated = true
					memberObj.eliminationTime = currentTime
					respawnToObby(memberObj.player)
				end
			end

			print(string.format("Team %s has been eliminated! (Score: %d)", team.name, team.questData.quest4Score))
		end
	end

	-- Set last standing team if there's only one team left
	for _, team in pairs(teamsTable) do
		if not team.isEliminated then
			lastStandingTeam.leader = team.leader
			lastStandingTeam.members = team.members
			lastStandingTeam.name = team.name
			lastStandingTeam.color = team.color

			lastStandingTeam.isEliminated = team.isEliminated
			lastStandingTeam.eliminationTime = team.eliminationTime

			lastStandingTeam.questData = team.questData
			
			print(string.format("Team %s continues to Quest 5! (Score: %d)", lastStandingTeam.name, lastStandingTeam.questData.quest4Score))
			break
		end
	end
end
