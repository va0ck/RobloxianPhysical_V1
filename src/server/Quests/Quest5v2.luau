--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quest5V2Map = workspace.Quest5V2

local Quest5v2Sound = SoundService.Quest5v2 ::Sound
local WhiteSound = SoundService.Whistle ::Sound

local Packages = ReplicatedStorage:WaitForChild("Packages")
local FolderNet = require(Packages.FolderNet)
local TagSettings = require(ReplicatedStorage.SharedModules.TagSettings)

local ActivateTagRE = FolderNet.GetRemoteEvent("Quest5v2", "ActivateTag")
local Quest5v2TaggedTarget = FolderNet.GetRemoteEvent("Quest5v2", "TaggedTarget")

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby

local lastStandingTeam = require(script.Parent.Parent.Tables).lastStandingTeam
local playersTable = require(script.Parent.Parent.Tables).playersTable
local _A_QUESTCOUNT = require(script.Parent.Parent.Quests.A_QUESTCOUNT)

local scriptConnection = nil::RBXScriptConnection?

return function()
	print("Starting Quest 5 V2...")
	_A_QUESTCOUNT.CURRENT_COUNT = 6
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

	Quest5v2Sound:Play()

	--Start Transition
	for _, playerObj in ipairs(activePlayers) do
		ReplicatedStorage.Remotes.CameraTransition:FireClient(playerObj.player, Quest5V2Map, transitionTime.Quest5V2, questMessages.Quest5V2)
	end
	task.wait(transitionTime.Quest5V2)

	--Spawn everyone in then countdown.
	for playerIndex, plrInfo in ipairs(activePlayers) do
		local player = plrInfo.player
		player:LoadCharacter()
	
		-- Get spawn part
		local spawnPart = spawnParts:FindFirstChild("Spawn" .. playerIndex)
		if spawnPart then
			-- Wait for character to load
			repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			-- Position at spawn
			if player.Character then
				player.Character:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(0, 3, 0)))
				
				local hrp = player.Character:FindFirstChild("HumanoidRootPart") ::Part
				if hrp then
					hrp.Anchored = true
				end
				ReplicatedStorage.Remotes.StartTimer:FireClient(player, os.time() + 3)
			end
		end
	end

	-- Wait for countdown
	task.wait(3)
	WhiteSound:Play()

	--Check for nextIndex function.
	local function grabNextAvaliablePlayer(playerNum: number)
		local maxTableLen = #activePlayers
		local currentCheck = ((playerNum) % maxTableLen) + 1
		print(`Max TableLen: {maxTableLen} \n| PlayerNum: {playerNum} \n| NextIndex: {currentCheck}`)

		return activePlayers[currentCheck]
	end

	--Start TagSystem
	for playerIndex, plrInfo in ipairs(activePlayers) do
		local player = plrInfo.player

		if player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart") ::Part
			if hrp then
				hrp.Anchored = false
			end

			--Grabbing non-elim player.
			local nextPlayer = grabNextAvaliablePlayer(playerIndex)
			ActivateTagRE:FireClient(player, nextPlayer.player.Character)
		end
	end

	scriptConnection = Quest5v2TaggedTarget.OnServerEvent:Connect(function(plrWhoTagged: Player)
		print(`TAG TRIGGERED BY {plrWhoTagged.Name}!`)

		local plrWhoTaggedIndex
		for index,v in ipairs(activePlayers) do
			if v.player.Name == plrWhoTagged.Name then
				plrWhoTaggedIndex = index
			end
		end
		local playerInfront = grabNextAvaliablePlayer(plrWhoTaggedIndex)
		print(`THEY TAGGED {playerInfront.player.Name}!`)

		local plrWhoTaggedChar = plrWhoTagged.Character
		local playerInfrontChar = playerInfront.player.Character
		if plrWhoTaggedChar and playerInfrontChar then
			print(`PASSED THROUGH CHARACTER CHECK TO ANTI-CHEAT CHECK.`)
			local plrWhoTaggedHrp = plrWhoTaggedChar:FindFirstChild("HumanoidRootPart") ::Part
			local playerInfrontHrp = playerInfrontChar:FindFirstChild("HumanoidRootPart") ::Part

			if plrWhoTaggedHrp and playerInfrontHrp then
				print(`PREFORMING DISTANCE CHECK NOW, FACTOR OF 1.5 IS APPLIED.`)
				local distanceCheck = (plrWhoTaggedHrp.Position - playerInfrontHrp.Position).Magnitude
				print(`DISTANCE WAS {distanceCheck}\n | NEEDED DISTANCE IS UNDER {TagSettings.TargetPromptDistance * 1.5}!`)

				if distanceCheck < (TagSettings.TargetPromptDistance * 1.5) then
					print(`WAS IN UNDER DISTANCE, NOW REMOVING PLAYERINFRONT.`)
					for i, p in ipairs(activePlayers) do
						if p.player.UserId == playerInfront.player.UserId then
							table.remove(activePlayers, i)
							break
						end
					end

					playerInfront.isEliminated = true
					playerInfront:Despawn()
					respawnToObby(playerInfront.player)
					print(`{playerInfront.player.Name} IS ELIMINATED!`)

					local nextPlayer = grabNextAvaliablePlayer(plrWhoTaggedIndex)
					ActivateTagRE:FireClient(plrWhoTagged, nextPlayer.player.Character)
					return
				else
					print(`FAILED THE DISTANCE CHECK, REVERTING BACK TO SAME TARGET.`)
				end
			end
		end

		ActivateTagRE:FireClient(plrWhoTagged, plrWhoTaggedChar)
	end)

	
	-- Wait until only 2 players remains
	while #activePlayers > 2 do
		task.wait(1)
	end
	WhiteSound:Play()
	Quest5v2Sound:Stop()

	--Cleanup Connection
	if scriptConnection then
		scriptConnection:Disconnect()
		scriptConnection = nil
	end

	--Cleanup TagPrompts
	ActivateTagRE:FireAllClients()

	-- Update lastStandingTeam with the remaining players
	lastStandingTeam.members = {}
	lastStandingTeam.isEliminated = false

	for _, playerObj in ipairs(activePlayers) do
		table.insert(lastStandingTeam.members, playerObj.player.UserId)
		playerObj:Despawn() -- Despawn them for the next challenge
	end
end