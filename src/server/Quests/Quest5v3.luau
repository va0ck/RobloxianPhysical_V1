--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Quest5V3Map = workspace.Quest5V3

local Quest5v3Sound = SoundService.Quest5v3 ::Sound
local WhiteSound = SoundService.Whistle ::Sound

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questsDuration = require(SettingsFolder.QuestDuration)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby

local lastStandingTeam = require(script.Parent.Parent.Tables).lastStandingTeam
local playersTable = require(script.Parent.Parent.Tables).playersTable


return function()
	print("Starting Quest 5 V3...")
	--// wait for transition on the client

	local questTime = questsDuration.Quest5V3

	-- Check if we have a last standing team
	if not lastStandingTeam or not lastStandingTeam.members then
		print("No last standing team found!")
		return
	end

	local pullupParts = Quest5V3Map.PullupParts

	-- Get active players
	local activePlayers = {} :: {PlayerModule.PlayerObject}
	for _, memberId in ipairs(lastStandingTeam.members) do
		local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
		if memberObj and not memberObj.isEliminated then
			table.insert(activePlayers, memberObj)
		end
	end

	if #activePlayers == 0 then
		print("No active players for pull-up challenge!")
		return
	end

	Quest5v3Sound.Volume = 0
	Quest5v3Sound:Play()
	for i = 0, 0.5, 0.02 do
		task.wait(0.01)
		Quest5v3Sound.Volume = i
	end

	for _, playerObj in ipairs(activePlayers) do
		ReplicatedStorage.Remotes.CameraTransition:FireClient(playerObj.player, Quest5V3Map, transitionTime.Quest5V3, questMessages.Quest5V3)
	end
	task.wait(transitionTime.Quest5V3)

	-- Track pullup counts
	local pullupCounts = {}
	for _, playerObj in ipairs(activePlayers) do
		pullupCounts[playerObj.player.UserId] = 0
	end

	-- Function to handle pullup count updates
	ReplicatedStorage.Remotes.UpdatePullupCount.OnServerInvoke = function(player)
		local playerObj = PlayerModule.GetPlayerObj(player.UserId, playersTable)
		if playerObj and not playerObj.isEliminated then
			-- Increment count
			pullupCounts[player.UserId] = (pullupCounts[player.UserId] or 0) + 1

			-- Get teammate's score
			local teammateScore = 0
			for _, otherPlayer in ipairs(activePlayers) do
				if otherPlayer.player.UserId ~= player.UserId then
					teammateScore = pullupCounts[otherPlayer.player.UserId] or 0
					break
				end
			end

			for _, otherPlayer in ipairs(activePlayers) do
				if otherPlayer.player.UserId == player.UserId then continue end
				ReplicatedStorage.Remotes.UpdatePullupScore:FireClient(otherPlayer.player, teammateScore, pullupCounts[player.UserId])
			end
			-- Return [player's score, teammate's score]
			return {pullupCounts[player.UserId], teammateScore}
		end
		return {0, 0}
	end

	-- Spawn and position players
	local playerIndex = 1
	for _, playerObj in ipairs(activePlayers) do
		-- Load character
		playerObj.player:LoadCharacter()

		-- Get pullup part
		local pullupPart = pullupParts:FindFirstChild("PullupPart" .. playerIndex)
		if pullupPart then
			-- Wait for character to load
			repeat task.wait() until playerObj.player.Character and 
				playerObj.player.Character:FindFirstChild("HumanoidRootPart") and
				playerObj.player.Character:FindFirstChild("Humanoid")

			local character = playerObj.player.Character
			
			if character then
				local rootPart = character:FindFirstChild("HumanoidRootPart")

				if rootPart and rootPart:IsA("BasePart") then
					-- Position character at pullup bar
					rootPart.CFrame = pullupPart.CFrame * CFrame.new(0, -2, 0) -- Adjust Y offset as needed

					-- Anchor character
					rootPart.Anchored = true
				end
			end

			playerIndex += 1
		end
	end

	-- Fire event to all active players
	for _, playerObj in ipairs(activePlayers) do
		ReplicatedStorage.Remotes.EnablePullupUI:FireClient(playerObj.player, questTime)
	end

	-- Wait for questTime seconds
	local startTime = os.time()
	WhiteSound:Play()

	for _, playerObj in pairs(activePlayers) do
		local player = playerObj.player
		if not player or playerObj.isEliminated then continue end

		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, startTime + questTime)
	end
	while os.time() - startTime < questTime do
		-- Update time remaining for all players
		-- local timeRemaining = questTime - (os.time() - startTime)
		task.wait(1)
	end

	-- Find winner (player with most pullups)
	local winnerObj = nil :: PlayerModule.PlayerObject | any
	local maxPullups = -1
	for _, playerObj in ipairs(activePlayers) do
		local count = pullupCounts[playerObj.player.UserId] or 0
		if count > maxPullups then
			maxPullups = count
			winnerObj = playerObj

			Remotes.DisplayWinner:FireClient(playerObj.player, true)
		end
	end

	-- Eliminate the loser
	Quest5v3Sound:Stop()
	WhiteSound:Play()
	for _, playerObj in ipairs(activePlayers) do
		if playerObj.userId ~= winnerObj.userId then
			playerObj.isEliminated = true
			respawnToObby(playerObj.player)
		end
		playerObj:Despawn()
	end

	print(string.format("Quest 5 V3 finished! Winner: %s with %d pullups!", winnerObj.player.Name, maxPullups))
end