--!strict
local Players = game:GetService("Players")

--RequiredModules
local PlayerModule = require(script.Parent.OOP.PlayerObject)
local playersTable = require(script.Parent.Tables).playersTable

return {
	--getActualTableSize is never used in scripts.
	getActualTableSize = function(givenTable)
		local size = 0
		for _, _ in pairs(givenTable) do
			size += 1
		end
		return size
	end,
	
	setupPlayersTable = function()
		local players = Players:GetPlayers()

		for i, player in pairs(players) do
			local playerObj = PlayerModule.new(player, i)
			table.insert(playersTable, playerObj)
		end
	end,
	
	manageLobby = require(script.ManageLobby),
	createTeams = require(script.CreateTeams),
	respawnToObby = require(script.RespawnToObby),
	setUpGameForStart = require(script.SetUpGameForStart),
}