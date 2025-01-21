--!strict
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Quest5V1Map = workspace.Quest5V1

local Quest5v1Sound = SoundService.Quest5v1 ::Sound
local WhiteSound = SoundService.Whistle ::Sound

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questImages = require(SettingsFolder.QuestImages)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby

local lastStandingTeam = require(script.Parent.Parent.Tables).lastStandingTeam
local playersTable = require(script.Parent.Parent.Tables).playersTable
local _A_QUESTCOUNT = require(script.Parent.Parent.Quests.A_QUESTCOUNT)


return function()
	print("Starting Quest 5 V1...")
	_A_QUESTCOUNT.CURRENT_COUNT = 5
	--// wait for transition on the client
	print("DOING TRANSITION")

	-- Check if we have a last standing team
	if not lastStandingTeam or not lastStandingTeam.members then
		print("No last standing team found!")
		return
	end

	Quest5v1Sound:Play()

	local stairsClimbers = Quest5V1Map.StairClimbers
	local floorHitbox = Quest5V1Map.FloorHitbox
	local treadmills = {}
	local hasEliminatedPlayer = false

	-- First pass: Set up treadmills and prepare spawns
	for i, memberId in ipairs(lastStandingTeam.members) do
		local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
		if memberObj and not memberObj.isEliminated then
			local climber = stairsClimbers:FindFirstChild("StairClimber" .. i)
			if climber then
				local treadmill = climber:FindFirstChild("Treadmill")
				if treadmill then
					-- Set up treadmill physics
					treadmill.Anchored = true
					treadmill.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					table.insert(treadmills, treadmill)
				end
			end
		end
	end

	if #treadmills == 0 then
		print("No treadmills found!")
		return
	end

	-- Second pass: Spawn and position all players
	for i, memberId in ipairs(lastStandingTeam.members) do
		local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
		if memberObj and not memberObj.isEliminated then
			-- Load character
			memberObj.player:LoadCharacter()

			-- Get stair climber
			local climber = stairsClimbers:FindFirstChild("StairClimber" .. i)
			if climber then
				-- Wait for character to load
				repeat task.wait() until memberObj.player.Character and 
					memberObj.player.Character:FindFirstChild("HumanoidRootPart") and
					memberObj.player.Character:FindFirstChild("Humanoid")

				local character = memberObj.player.Character
				
				if character then
					local rootPart = character:FindFirstChild("HumanoidRootPart")

					-- Position character on treadmill
					if rootPart and rootPart:IsA("BasePart") then
						local spawnPoint = climber:FindFirstChild("SpawnPart")
						
						if spawnPoint then
							rootPart.CFrame = spawnPoint.CFrame
						else
							rootPart.CFrame = climber.CFrame * CFrame.new(0, 3, 0) -- Fallback position
						end
						
						rootPart.Anchored = false
					end
				end

				ReplicatedStorage.Remotes.CameraTransition:FireClient(memberObj.player, Quest5V1Map, transitionTime.Quest5V1, questMessages.Quest5V1, questImages.Quest5V1)
			end
		end
	end

	task.wait(transitionTime.Quest5V1)

	-- Set up floor hitbox detection
	local function eliminatePlayer(player)
		if not hasEliminatedPlayer then
			hasEliminatedPlayer = true
			local playerObj = PlayerModule.GetPlayerObj(player.UserId, playersTable)
			if playerObj then
				playerObj.isEliminated = true
				playerObj:Despawn()
				respawnToObby(playerObj.player)
				print(string.format("Player %s has been eliminated!", player.Name))
				return true
			end
		end
		return false
	end

	floorHitbox.Touched:Connect(function(hit)
		if not hasEliminatedPlayer and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				eliminatePlayer(player)
			end
		end
	end)

	-- Wait 3 seconds before starting treadmills
	Remotes.StartTimer:FireAllClients(os.time() + 3)
	task.wait(3)

	WhiteSound:Play()
	-- Gradually increase treadmill speed
	local baseSpeed = 5  -- Starting speed
	local speedIncrement = 1  -- Speed increase per second
	local maxSpeed = 100  -- Maximum speed
	local currentSpeed = baseSpeed

	-- Set initial velocity for all treadmills
	print("Starting treadmills...")
	for _, treadmill in ipairs(treadmills) do
		-- Convert world velocity to local velocity using CFrame
		treadmill.AssemblyLinearVelocity = treadmill.CFrame.UpVector * -baseSpeed
	end

	-- Increase speed until someone is eliminated
	while not hasEliminatedPlayer do
		-- Increase speed for all treadmills
		if currentSpeed < maxSpeed then
			currentSpeed += speedIncrement
			for _, treadmill in ipairs(treadmills) do
				-- Convert world velocity to local velocity using CFrame
				treadmill.AssemblyLinearVelocity = treadmill.CFrame.UpVector * -currentSpeed
			end
			print("Increased treadmill speed to: " .. currentSpeed)
		end

		task.wait(1)
	end

	-- Stop treadmills
	Quest5v1Sound:Stop()
	WhiteSound:Play()
	for _, treadmill in ipairs(treadmills) do
		treadmill.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end

	-- Despawn remaining players
	for _, memberId in ipairs(lastStandingTeam.members) do
		local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
		if memberObj and not memberObj.isEliminated then
			memberObj:Despawn()
		end
	end
end