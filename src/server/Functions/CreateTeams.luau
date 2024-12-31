--!strict
local teamTemplate = require(script.Parent.Parent.Settings.TeamColors)
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)

--Return function
return function()
	local activePlayers = {} :: {PlayerModule.PlayerObject}
	for _, plrInfo in pairs(playersTable) do
		if not plrInfo.isEliminated then
			table.insert(activePlayers, plrInfo)
		end
	end

	-- Sort by Quest 1 placement (lowest number = best placement)
	table.sort(activePlayers, function(a, b)
		return a:GetQuest1Placement(playersTable) < b:GetQuest1Placement(playersTable)
	end)

	-- Create teams with top players as leaders, filling each team to 5 players
	local playersPerTeam = 5

	-- Calculate how many complete teams we can make
	local numTeams = math.ceil(#activePlayers / playersPerTeam)
	numTeams = math.min(numTeams, #teamTemplate) -- Don't exceed template count

	print(`{numTeams} is avaliable.`)
	for i = 1, numTeams do
		local startIndex = (i - 1) * playersPerTeam + 1
		local teamMembers = {} :: {number}

		-- Get 5 players for this team
		for j = 0, playersPerTeam - 1 do
			local playerIndex = startIndex + j
			if activePlayers[playerIndex] then
				table.insert(teamMembers, activePlayers[playerIndex].userId)
				activePlayers[playerIndex].team = teamTemplate[i].name --Unsure about this type error.
			end
		end

		-- Create the team
		table.insert(teamsTable, {
			leader = teamMembers[1], -- First player is the leader
			members = teamMembers,
			name = teamTemplate[i].name,
			color = teamTemplate[i].color,

			isEliminated = false,
			eliminationTime = nil,

			questData = {
				quest2Finished = false,
				quest2MembersReached = {},
				quest2FinishTime = nil,
				quest2ObjectsPlaced = 0,

				quest3Finished = false,
				quest3FinishTime = nil,

				quest4Finished = false,
				quest4FinishTime = nil,
			}
		})
	end
end