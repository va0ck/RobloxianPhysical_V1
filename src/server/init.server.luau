--!strict
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- [[Required Modules]]
local PlayerModule = require(script.OOP.PlayerObject)
local REGULAR_VOLUME = require(script.Settings.REGULAR_VOLUME)

-- [[Tables]]
local playersTable = require(script.Tables).playersTable
local teamsTable = require(script.Tables).teamsTable
-- local lastStandingTeam = require(script.Tables).lastStandingTeam

-- [[Functions]]
local setUpGameForStart = require(script.Functions).setUpGameForStart
local setUpPlayersTable = require(script.Functions).setupPlayersTable
-- local respawnToObby = require(script.Functions).respawnToObby
local createTeams = require(script.Functions).createTeams

-- [[MainFunctions]]
local manageLobby = require(script.Functions).manageLobby
local startQuest1 = require(script.Quests.Quest1)
local startTeamPick = require(script.TeamPick.StartTeamPick)
local createTeamsLeaderStats = require(script.TeamPick.CreateTeamsLeaderStats)
local startQuest2 = require(script.Quests.Quest2)
local startQuest3 = require(script.Quests.Quest3)
local startQuest4 = require(script.Quests.Quest4)

local startQuest5V1 = require(script.Quests.Quest5v1)
local startQuest5V2 = require(script.Quests.Quest5v2)
local startQuest5V3 = require(script.Quests.Quest5v3)

--[[Teleport Back]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local LOBBY_ID = 94222366715596
local TeleportLobby = FolderNet.GetRemoteEvent("GAME", "TELEPORT_LOBBY")
local SafeTeleport = require(game.ReplicatedStorage.SharedModules.SafeTeleport)

--[[DON'T MUTE AUDIOS]]
local EXEMPT_AUDIOS = require(script.Settings.EXEMPT_AUDIOS)

-----------------------------------
--//MAIN FUNCTIONS ROLL THROUGH//--
-----------------------------------

local function startGame()
	--Setup to make audios muteable.
	for _, v in pairs(SoundService:GetDescendants()) do
		if v:IsA("Sound") and (not table.find(EXEMPT_AUDIOS, v.Name)) then
			v:AddTag("Muteable")
			v:SetAttribute("NormalVolume", REGULAR_VOLUME)
			v.Volume = REGULAR_VOLUME
		end
	end

	--Main Linear Flow.
    manageLobby()
    setUpPlayersTable()
    setUpGameForStart()

	startQuest1()
	
	createTeams()
    startTeamPick()
	createTeamsLeaderStats()
	
    startQuest2()
    startQuest3()
	startQuest4()
	
    startQuest5V1()
    startQuest5V2()
    startQuest5V3()
    print("Game finished!")
end

Players.PlayerRemoving:Connect(function(player)
	local plrInfo = PlayerModule.GetPlayerObj(player.UserId, playersTable)
	
	if plrInfo then
		plrInfo:Eliminate()
	end
	
	--Make sure to swap leaders if leader leaves if that's an issue. TODO.
	
	--Checking if they're in a group and remove them.
	for tableIndex, selectedTeamTable in pairs(teamsTable) do
		for memberIndex, memberId in ipairs(selectedTeamTable.members) do
			if memberId == player.UserId then
				table.remove(teamsTable[tableIndex].members, memberIndex)
			end
		end
	end
	
	--[[
		End line isn't really
		needed imo since they
		already left the game.
	]]
    --respawnToObby(player)
end)

TeleportLobby.OnServerEvent:Connect(function(plr)
	SafeTeleport(LOBBY_ID, {plr})
end)

startGame()