--!strict
local Teams = game:GetService("Teams")

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local teamsTable = require(script.Parent.Parent.Tables).teamsTable
local playersTable = require(script.Parent.Parent.Tables).playersTable

return function()
	for _, team in pairs(teamsTable) do
		-- Create team
		local robloxTeam = Instance.new("Team")
		robloxTeam.Name = team.name
		print("TEAM COLOR: ", team.color)
		robloxTeam.TeamColor = team.color or BrickColor.random()
		robloxTeam.Parent = Teams

		task.wait(0.1)

		-- Assign all members to team
		for _, memberId in ipairs(team.members) do
			local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
			if memberObj then
				memberObj.player.Team = robloxTeam
				memberObj.player.TeamColor = robloxTeam.TeamColor
			end
		end
	end
end