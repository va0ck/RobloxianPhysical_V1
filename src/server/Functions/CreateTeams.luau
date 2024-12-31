--!strict
local teamTemplate = require(script.Parent.Parent.Settings.TeamColors)
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)

-- Create teams with top players as leaders, filling each team to 5 players
local playersPerTeam = require(script.Parent.Parent.Settings.PlayersPerTeam)

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

	-- Calculate how many complete teams we can make
	local numTeams = math.ceil(#activePlayers / playersPerTeam)
	numTeams = math.min(numTeams, #teamTemplate) -- Don't exceed template count

	print(`{numTeams} team(s) is avaliable.`)
	for i = 1, numTeams do

		--Puts top player in team.
		local teamMembers = {} :: {number}
		for plrIndex, plrInfo in ipairs(activePlayers) do
			if (not plrInfo.team) then
				plrInfo.team = teamTemplate[i].name
				table.insert(teamMembers, plrInfo.userId)
				break
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