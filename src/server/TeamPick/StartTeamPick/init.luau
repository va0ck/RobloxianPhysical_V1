--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FolderNet = require(ReplicatedStorage.Packages["folder-net"])
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local REPickMember = FolderNet.GetRemoteEvent("TeamPick", "PickMember")
local REPickMemberTimer = FolderNet.GetRemoteEvent("TeamPick", "PickMemberTimer")

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questMessages = require(SettingsFolder.QuestMessages)
local questDuration = require(SettingsFolder.QuestDuration)

local TeamPick = SoundService.TeamPick ::Sound

-- Create teams with top players as leaders, filling each team to 5 players
local playersPerTeam = require(script.Parent.Parent.Settings.PlayersPerTeam)

--Maps
local TeamPickMap = workspace.TeamPick

--Connetion
local _teamLeaderConnection = nil :: RBXScriptConnection?

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

		Remotes.CameraTransition:FireClient(player, TeamPickMap, transitionTime.TeamPick, questMessages.TeamPick)
	end

	-- Wait for transition to complete
	task.wait(transitionTime.TeamPick)

	-- Get all non-team players
	local function getNonTeamPlayers() --Server
		local available = {}
		for _, plrInfo in pairs(playersTable) do
			if (plrInfo.isEliminated == false) and (not plrInfo.team) then
				table.insert(available, plrInfo)
			end
		end
		return available
	end

	-- StartTimer
	local startTime = os.time()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end

		Remotes.StartTopTimer:FireClient(player, startTime + questDuration.TeamPick)
	end

	--Creates a endpoint for team leaders.
	local allTeamLeaderObj = {} :: {PlayerModule.PlayerObject}
	for _, team in pairs(teamsTable) do
		local leaderObj = PlayerModule.GetPlayerObj(team.leader, playersTable)
		if not leaderObj then
			continue
		end

		table.insert(allTeamLeaderObj, leaderObj)
		REPickMember:FireClient(leaderObj.player, getNonTeamPlayers())
		REPickMemberTimer:FireClient(leaderObj.player, startTime + questDuration.TeamPick)

		_teamLeaderConnection = REPickMember.OnServerEvent:Connect(function(plr: Player, pickedUserId: number)
			if plr.UserId ~= team.leader then
				return
			end

			if pickedUserId then
				local pickedPlayer = PlayerModule.GetPlayerObj(pickedUserId, playersTable)
				if pickedPlayer and (not pickedPlayer.team) then
					pickedPlayer.team = team.name

					table.insert(team.members, pickedUserId)
					print(string.format("Leader %s picked member %s", leaderObj.name, pickedPlayer.name))
				end
			end

			--Sends updated list of avaliable players if not full.
			if #team.members < playersPerTeam then
				--Make sure all team leaders recieves an updated list.
				for _, teamLeaderObj in pairs(allTeamLeaderObj) do
					REPickMember:FireClient(teamLeaderObj.player, getNonTeamPlayers())
				end
			else
				--Removes them so they don't recieve any more updates.
				for indexLeader, leader in ipairs(allTeamLeaderObj) do
					if leader.userId == leaderObj.userId then
						table.remove(allTeamLeaderObj, indexLeader)
					end
				end
				
				--Empty table to signal GUI should be removed.
				REPickMember:FireClient(leaderObj.player, {})
			end
		end)
	end

	-- Keep picking until everyone has a team.
	while #getNonTeamPlayers() > 0 do
		if (os.time() - startTime) > questDuration.TeamPick then
			break
		end
		task.wait(1)
	end


	--Clear up connections regarding with _teamLeadersConnection.
	--This just ends the pick options for them.
	if _teamLeaderConnection then
		_teamLeaderConnection:Disconnect()
		_teamLeaderConnection = nil
	end
	REPickMember:FireAllClients({}) --Empty table to indicate to remove GUI.


	-- Picks random if someone wasn't picked within the time limit. 
	local availablePlayers = getNonTeamPlayers()
	for _,v in pairs(availablePlayers) do
		for _, teamObj in pairs(teamsTable) do
			local getCurrentPlayerObj = PlayerModule.GetPlayerObj(v.userId, playersTable)
			if #teamObj.members < playersPerTeam and (not getCurrentPlayerObj.team) then
				getCurrentPlayerObj.team = teamObj.name
				table.insert(teamObj.members, v.userId)
			end
		end
	end

	-- First team to end team fill algorithm. [LIKE BROKEN CODE NGL.]
	-- for _, teamObj in pairs(teamsTable) do
	-- 	--Example: (If team has 4 players less than 5) and (Still nonTeamPlayers there.)
	-- 	if #teamObj.members < playersPerTeam and (#getNonTeamPlayers() > 0) then
	-- 		repeat
	-- 			local availablePlayers = getNonTeamPlayers()
	-- 			local randomIndex = math.random(1, #availablePlayers)
	-- 			local pickedUserId = availablePlayers[randomIndex].userId
	-- 			table.insert(teamObj.members, pickedUserId)

	-- 			--Repeat until (teamObj has 5 or more members) or (nonTeamPlayers are gone.)
	-- 		until (#teamObj.members >= playersPerTeam) or (#getNonTeamPlayers() > 0)
	-- 	end
	-- end

	-- Clean up and final teams list.
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

	--Clear timer going on.
	ReplicatedStorage.Remotes.StartTopTimer:FireAllClients(0)
end