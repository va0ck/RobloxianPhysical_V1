--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TagTool = ReplicatedStorage.Tools.Tag

local Quest5V2Map = workspace.Quest5V2

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby

local lastStandingTeam = require(script.Parent.Parent.Tables).lastStandingTeam
local playersTable = require(script.Parent.Parent.Tables).playersTable


return function()
	print("Starting Quest 5 V2...")
	--// wait for transition on the client
	print("DOING TRANSITION")

	-- Check if we have a last standing team
	if not lastStandingTeam or not lastStandingTeam.members then
		print("No last standing team found!")
		return
	end

	local spawnParts = Quest5V2Map.SpawnParts

	-- Create ordered list of active players
	local activePlayers = {}
	for _, memberId in ipairs(lastStandingTeam.members) do
		local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
		if memberObj and not memberObj.isEliminated then
			table.insert(activePlayers, memberObj)
		end
	end

	if #activePlayers < 2 then
		print("Not enough players for tag game!")
		return
	end

	-- Function to update who each player can tag
	local function updateTagTargets()
		local targets = {}
		for i, player in ipairs(activePlayers) do
			local nextIndex = i % #activePlayers + 1
			targets[player.player.UserId] = activePlayers[nextIndex].player.UserId
		end
		return targets
	end

	-- Initial tag targets
	local tagTargets = updateTagTargets()

	-- Spawn players and give them tag tools
	local playerIndex = 1
	local toolConnections = {} -- Store connections for cleanup

	for _, playerObj in ipairs(activePlayers) do
		ReplicatedStorage.Remotes.CameraTransition:FireClient(playerObj.player, Quest5V2Map, transitionTime.Quest5V2, questMessages.Quest5V2)
	end

	task.wait(transitionTime.Quest5V2)

	for _, playerObj in ipairs(activePlayers) do
		-- Load character
		playerObj.player:LoadCharacter()

		-- Get spawn part
		local spawnPart = spawnParts:FindFirstChild("Spawn" .. playerIndex)
		if spawnPart then
			-- Wait for character to load
			repeat task.wait() until playerObj.player.Character and playerObj.player.Character:FindFirstChild("HumanoidRootPart")

			-- Position at spawn
			if playerObj.player.Character then
				playerObj.player.Character:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(0, 3, 0)))
			end

			-- Give and equip tag tool
			local tool = TagTool:Clone()
			tool.CanBeDropped = false

			-- Handle tagging with debounce
			local canTag = true
			local connection = tool.Handle.Touched:Connect(function(hit)
				if not canTag then return end

				if hit.Parent then
					local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
					if hitPlayer and hitPlayer.UserId == tagTargets[playerObj.player.UserId] then
						canTag = false -- Debounce

						-- Valid tag
						local hitPlayerObj = PlayerModule.GetPlayerObj(hitPlayer.UserId, playersTable)
						if hitPlayerObj and not hitPlayerObj.isEliminated then
							-- Eliminate tagged player
							hitPlayerObj.isEliminated = true
							hitPlayerObj:Despawn()
							print(string.format("Player %s tagged and eliminated Player %s!", playerObj.player.Name, hitPlayer.Name))
							respawnToObby(hitPlayer)

							-- Remove from active players
							for i, p in ipairs(activePlayers) do
								if p.player.UserId == hitPlayer.UserId then
									table.remove(activePlayers, i)
									break
								end
							end

							-- Update tag targets if more than one player remains
							if #activePlayers > 2 then
								-- Clean up old tools
								for _, conn in pairs(toolConnections) do
									conn:Disconnect()
								end
								toolConnections = {}

								-- Update targets and respawn remaining players
								tagTargets = updateTagTargets()

								-- Respawn remaining players with new tools
								local respawnIndex = 1
								for _, p in ipairs(activePlayers) do
									if not p.isEliminated then
										-- Respawn player
										p.player:LoadCharacter()

										-- Wait for character and position
										local respawnPart = spawnParts:FindFirstChild("Spawn" .. respawnIndex)
										if respawnPart then
											repeat task.wait() until p.player.Character and p.player.Character:FindFirstChild("HumanoidRootPart")
											
											if p.player.Character then
												p.player.Character:PivotTo(CFrame.new(respawnPart.Position + Vector3.new(0, 3, 0)))
											end

											-- Give new tool
											local newTool = TagTool:Clone()
											newTool.CanBeDropped = false
											newTool.Parent = p.player.Character

											respawnIndex += 1
										end
									end
								end

								-- Announce new targets
								for _, p in ipairs(activePlayers) do
									local targetObj = PlayerModule.GetPlayerObj(tagTargets[p.player.UserId], playersTable)
									if targetObj then
										print(string.format("Player %s can now tag Player %s", p.player.Name, targetObj.player.Name))
									end
								end
							else
								-- We have exactly 2 players left, clean up and proceed
								print("2 players remaining! Moving to next challenge.")

								-- Clean up all connections
								for _, conn in pairs(toolConnections) do
									conn:Disconnect()
								end

								-- Update lastStandingTeam with the remaining players
								lastStandingTeam.members = {}
								lastStandingTeam.isEliminated = false
								
								for _, p in ipairs(activePlayers) do
									table.insert(lastStandingTeam.members, p.player.UserId)
									p:Despawn() -- Despawn them for the next challenge
								end

								return -- Exit the function to proceed to next challenge
							end
						end

						task.wait(0.5) -- Debounce time
						canTag = true
					end
				end
			end)

			table.insert(toolConnections, connection)

			tool.Parent = playerObj.player.Character
			playerIndex += 1
		end
	end

	-- Announce initial targets
	for _, playerObj in ipairs(activePlayers) do
		local targetObj = PlayerModule.GetPlayerObj(tagTargets[playerObj.player.UserId], playersTable)
		if targetObj then
			print(string.format("Player %s can tag Player %s", playerObj.player.Name, targetObj.player.Name))
		end
	end

	-- Wait until only 1 player remains
	while #activePlayers > 2 do
		task.wait(1)
	end

	-- Clean up all connections
	for _, connection in pairs(toolConnections) do
		connection:Disconnect()
	end

	-- Update lastStandingTeam with the remaining players
	lastStandingTeam.members = {}
	lastStandingTeam.isEliminated = false

	for _, playerObj in ipairs(activePlayers) do
		table.insert(lastStandingTeam.members, playerObj.player.UserId)
		playerObj:Despawn() -- Despawn them for the next challenge
	end
end