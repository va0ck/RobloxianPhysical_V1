--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quest2Map = workspace.Quest2

local BlockTool = ReplicatedStorage.Tools.Block
local CircleTool = ReplicatedStorage.Tools.Circle

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
	print("Starting Quest 2...")
	--// wait for transition on the client
	print("DOING TRANSITION")
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.CameraTransition:FireClient(player, Quest2Map, transitionTime.Quest2, questMessages.Quest2, questImages.Quest2)
	end

	-- Wait for transition to complete
	task.wait(transitionTime.Quest2)

	--// spawning characters in their zones
	local teamSpawns = Quest2Map.TeamSpawns
	local pickupAreas = Quest2Map.PickupAreas
	local blockPlacements = Quest2Map.BlockPlacements
	local finishLines = Quest2Map.FinishLines

	-- Spawn each team at their respective spawn
	for i, team in pairs(teamsTable) do
		local teamSpawn = teamSpawns:FindFirstChild("Team" .. i)
		if teamSpawn then
			local spawnPart = teamSpawn:FindFirstChild("SpawnPart")
			local spawnBackPart = teamSpawn:FindFirstChild("SpawnBackPart")
			-- Get spawn area bounds
			local size = spawnPart.Size
			local position = spawnPart.Position

			-- Function to spawn at random position
			local function spawnAtRandom(character)
				local randomX = position.X + (math.random() - 0.5) * size.X
				local randomZ = position.Z + (math.random() - 0.5) * size.Z
				character:PivotTo(CFrame.new(Vector3.new(randomX, position.Y + 3, randomZ)))
			end

			-- Set up respawn on touching back part
			spawnBackPart.Touched:Connect(function(hit)
				local character = hit.Parent
				local player = Players:GetPlayerFromCharacter(character)
				if player then
					local playerObj = PlayerModule.GetPlayerObj(player.UserId, playersTable)
					if playerObj and playerObj.team == team.name then
						spawnAtRandom(character)
					end
				end
			end)

			-- Spawn each team member at a random position within the spawn area
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					-- Load character
					memberObj.player:LoadCharacter()

					-- Wait for character to load
					repeat task.wait() until memberObj.player.Character and memberObj.player.Character:FindFirstChild("HumanoidRootPart")

					if memberObj.player.Character then
						spawnAtRandom(memberObj.player.Character)
					end
				end
			end
		end

		local pickupArea = pickupAreas:FindFirstChild("PickupArea" .. i)
		if pickupArea then
			local pickupBlocks = pickupArea.Blocks
			local pickupCircles = pickupArea.Circles

			-- Add prompts to blocks
			for _, block in ipairs(pickupBlocks:GetChildren()) do
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Pick Up Block"
				prompt.ObjectText = "Building Block"
				prompt.HoldDuration = 0
				prompt.RequiresLineOfSight = false
				prompt.Parent = block

				prompt.Triggered:Connect(function(player)
					-- Clear inventory
					player.Backpack:ClearAllChildren()
					if player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool:IsA("Tool") then
								tool:Destroy()
							end
						end
					end

					local tool = BlockTool:Clone()
					tool.Parent = player.Backpack
				end)
			end

			-- Add prompts to circles
			for _, circle in ipairs(pickupCircles:GetChildren()) do
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Pick Up Circle"
				prompt.ObjectText = "Building Circle"
				prompt.HoldDuration = 0
				prompt.RequiresLineOfSight = false
				prompt.Parent = circle

				prompt.Triggered:Connect(function(player)
					-- Clear inventory
					player.Backpack:ClearAllChildren()
					if player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool:IsA("Tool") then
								tool:Destroy()
							end
						end
					end

					local tool = CircleTool:Clone()
					tool.Parent = player.Backpack
				end)
			end
		end

		local blockPlacement = blockPlacements:FindFirstChild("Team" .. i .. "Blocks")
		if blockPlacement then
			local blockPlace = blockPlacement.BlockPlace
			local circlePlace = blockPlacement.CirclePlace

			-- Add prompts to block placements
			for _, block in ipairs(blockPlace:GetChildren()) do
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Place Block"
				prompt.ObjectText = "Building Spot"
				prompt.HoldDuration = 0
				prompt.RequiresLineOfSight = false
				prompt.MaxActivationDistance = 10
				prompt.Parent = block

				prompt.Triggered:Connect(function(player)
					-- Check if player has block tool
					local hasBlockTool = false
					local toolToRemove = nil

					-- Check backpack
					for _, tool in ipairs(player.Backpack:GetChildren()) do
						if tool.Name == BlockTool.Name then
							hasBlockTool = true
							toolToRemove = tool
							break
						end
					end

					-- Check character if not found in backpack
					if not hasBlockTool and player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool.Name == BlockTool.Name then
								hasBlockTool = true
								toolToRemove = tool
								break
							end
						end
					end

					if hasBlockTool and toolToRemove then
						toolToRemove:Destroy()
						block.CanCollide = true
						block.Transparency = 0
						prompt:Destroy()

						-- Increment team's placed objects count
						local playerObj = PlayerModule.GetPlayerObj(player.UserId, playersTable)
						if playerObj then
							for _, teamV2 in pairs(teamsTable) do
								if teamV2.name == playerObj.team then
									teamV2.questData.quest2ObjectsPlaced += 1
									break
								end
							end
						end
					end
				end)
			end

			-- Add prompts to circle placements
			for _, circle in ipairs(circlePlace:GetChildren()) do
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Place Circle"
				prompt.ObjectText = "Building Spot"
				prompt.HoldDuration = 0
				prompt.RequiresLineOfSight = false
				prompt.MaxActivationDistance = 20
				prompt.Parent = circle

				prompt.Triggered:Connect(function(player)
					-- Check if player has circle tool
					local hasCircleTool = false
					local toolToRemove = nil

					-- Check backpack
					for _, tool in ipairs(player.Backpack:GetChildren()) do
						if tool.Name == CircleTool.Name then
							hasCircleTool = true
							toolToRemove = tool
							break
						end
					end

					-- Check character if not found in backpack
					if not hasCircleTool and player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool.Name == CircleTool.Name then
								hasCircleTool = true
								toolToRemove = tool
								break
							end
						end
					end

					if hasCircleTool and toolToRemove then
						toolToRemove:Destroy()
						circle.CanCollide = true
						circle.Transparency = 0
						prompt:Destroy()

						-- Increment team's placed objects count
						local playerObj = PlayerModule.GetPlayerObj(player.UserId, playersTable)
						if playerObj then
							for _, team in pairs(teamsTable) do
								if team.name == playerObj.team then
									team.questData.quest2ObjectsPlaced += 1
									break
								end
							end
						end
					end
				end)
			end
		end

		local finishLine = finishLines:FindFirstChild("FinishTeam" .. i)
		if finishLine then
			local finishPart = finishLine:FindFirstChild("FinishPart")
			local playersReachedText = finishPart.BillboardGui:FindFirstChild("PlayersReached")

			finishPart.Touched:Connect(function(hit)
				if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
					local plr = Players:GetPlayerFromCharacter(hit.Parent)
					if plr then
						local plrInfo = PlayerModule.GetPlayerObj(plr.UserId, playersTable)
						if plrInfo and plrInfo.team == team.name then
							-- Check if player hasn't already reached
							local alreadyReached = false
							for _, reachedId in ipairs(team.questData.quest2MembersReached) do
								if reachedId == plr.UserId then
									alreadyReached = true
									break
								end
							end

							if not alreadyReached then
								-- Add player to reached list
								table.insert(team.questData.quest2MembersReached, plr.UserId)

								-- Update billboard text
								playersReachedText.Text = string.format("%d/%d", 
									#team.questData.quest2MembersReached, 
									#team.members)

								-- Check if all active team members have reached
								local allReached = true
								for _, memberId in ipairs(team.members) do
									local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
									
									if memberObj and memberObj.player then -- Check if member is still active	
										local hasReached = false
										for _, reachedId in ipairs(team.questData.quest2MembersReached) do
											if reachedId == memberId then
												hasReached = true
												break
											end
										end
										
										if not hasReached then
											allReached = false
											break
										end
									end
								end

								-- If all active members reached, complete the quest
								if allReached then
									team.questData.quest2Finished = true
									team.questData.quest2FinishTime = os.time()
									print(string.format("Team %s has completed Quest 2!", team.name))
								end
							end
						end
					end
				end
			end)

			-- Initialize billboard text
			playersReachedText.Text = string.format("%d/%d", 
				#team.questData.quest2MembersReached, 
				#team.members)
		end
	end

	-- Wait for all teams to finish or timeout
	local function areAllTeamsFinished()
		for _, team in pairs(teamsTable) do
			if not team.questData.quest2FinishTime and not team.isEliminated then
				return false
			end
		end
		return true
	end

	-- Wait for teams to finish (with timeout)
	local startTime = os.time()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, startTime + questsDuration.Quest2)
	end

	while not areAllTeamsFinished() do
		if os.time() - startTime > questsDuration.Quest2 then
			break
		end
		task.wait(1)
	end

	--// print results
	for i, teamInfo in pairs(teamsTable) do
		print(string.format("Team %s - Objects Placed: %d", 
			teamInfo.name, 
			teamInfo.questData.quest2ObjectsPlaced))
	end

	-- Sort teams by objects placed
	local sortedTeams = {}
	for _, team in pairs(teamsTable) do
		table.insert(sortedTeams, team)
	end
	table.sort(sortedTeams, function(a, b)
		return a.questData.quest2ObjectsPlaced > b.questData.quest2ObjectsPlaced
	end)

	-- Eliminate teams with least objects placed
	local currentTime = os.time()
	for i, team in ipairs(sortedTeams) do
		-- Despawn all team members regardless of placement
		for _, memberId in ipairs(team.members) do
			local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
			if memberObj then
				memberObj:Despawn()
			end
		end

		if i > 3 then -- Eliminate teams with least objects placed
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

			print(string.format("Team %s has been eliminated! (Objects Placed: %d)", team.name, team.questData.quest2ObjectsPlaced))
		else
			print(string.format("Team %s advances! (Objects Placed: %d)", team.name, team.questData.quest2ObjectsPlaced))
		end
	end
	
	--Clear timer going on.
	ReplicatedStorage.Remotes.StartTopTimer:FireAllClients(0)
end