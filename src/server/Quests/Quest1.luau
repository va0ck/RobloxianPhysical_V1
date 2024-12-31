--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quest1Map = workspace.Quest1
local treadmillAnimation = "rbxassetid://100328792765925"

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questsDuration = require(SettingsFolder.QuestDuration)
local questImages = require(SettingsFolder.QuestImages)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby
local playersTable = require(script.Parent.Parent.Tables).playersTable

--Main Function
return function()
	--// spawning characters in their treadmills
	local treadmills = Quest1Map.Treadmills
	local floorHitbox = Quest1Map.FloorHitbox
	local treadmillAnimationTracks = {}
	local numPlayers = 0

	-- Spawn all players first
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player then continue end
		if plrInfo.isEliminated then continue end

		local playerTreadmill = treadmills:FindFirstChild("Treadmill" .. plrInfo.playerIndex)
		local spawnPart = playerTreadmill:FindFirstChild("SpawnPart")

		if spawnPart then
			-- Spawn the character
			player:LoadCharacter()
			
			local playerCharacter = player.Character
			repeat
				task.wait(0.1)
			until playerCharacter
			
			if playerCharacter then
				local HRP = playerCharacter:WaitForChild("HumanoidRootPart", 5)
				task.wait(0.1) -- Wait for character to load

				-- Position the character
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and HRP then
					player.Character:PivotTo(spawnPart.CFrame)
				end

				numPlayers += 1
			end
		end
	end

	-- Start camera transitions for all players
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.CameraTransition:FireClient(player, Quest1Map, transitionTime.Quest1, questMessages.Quest1, questImages.Quest1)
	end

	-- Wait for camera transition
	task.wait(transitionTime.Quest1)

	-- Start 3-second countdown for all players
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		ReplicatedStorage.Remotes.StartTimer:FireClient(player, os.time() + 3)
	end

	-- Wait for countdown
	task.wait(3)

	-- Start quest timer and animations for all players
	local questStartTime = os.time()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		local playerTreadmill = treadmills:FindFirstChild("Treadmill" .. plrInfo.playerIndex)
		local treadmillAnimator = playerTreadmill:FindFirstChild("AnimationController")

		-- Play treadmill animation
		local animation = Instance.new("Animation")
		animation.AnimationId = treadmillAnimation
		local animTrack = treadmillAnimator:LoadAnimation(animation)
		treadmillAnimationTracks[plrInfo.userId] = animTrack
		animTrack:Play()

		-- Start the main quest timer
		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, questStartTime + questsDuration.Quest1)
	end

	-- Set up elimination detection
	local floorHitboxConn = floorHitbox.Touched:Connect(function(part)
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local plr = Players:GetPlayerFromCharacter(part.Parent)
			if plr then
				local plrInfo = PlayerModule.GetPlayerObj(plr.UserId, playersTable)
				plrInfo:EliminateQuest1()
			end
		end
	end)

	-- Adjust speed increases based on total duration
	task.wait(questsDuration.Quest1 * 0.375) -- After 37.5% of time
	for plrId, track in pairs(treadmillAnimationTracks) do
		track:AdjustSpeed(2)
	end

	task.wait(questsDuration.Quest1 * 0.375) -- After 75% of time
	for plrId, track in pairs(treadmillAnimationTracks) do
		track:AdjustSpeed(3)
	end

	task.wait(questsDuration.Quest1 * 0.25) -- Remaining 25% of time
	floorHitboxConn:Disconnect()
	floorHitboxConn = nil

	-- Stop all animations
	for plrId, track in pairs(treadmillAnimationTracks) do
		track:Stop()
		treadmillAnimationTracks[plrId] = nil
	end

	-- Process eliminations
	for _, plrInfo in playersTable do
		local quest1Placement = plrInfo:GetQuest1Placement(playersTable)
		local gamePlacement = plrInfo:GetFinalPlacement(playersTable)
		print(plrInfo.name, " QUEST 1 PLACEMENT: ", quest1Placement)
		print(plrInfo.name, " QUEST 1 GAME PLACEMENT: ", gamePlacement)
		if quest1Placement > 25 then
			plrInfo:Eliminate()
			respawnToObby(plrInfo.player)
			task.wait(0.1)
		end
		plrInfo:Despawn()
	end
end