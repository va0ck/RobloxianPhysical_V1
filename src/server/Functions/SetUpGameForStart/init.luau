--!strict
local Players = game:GetService("Players")
local kickIncomingPlayers = require(script.KickIncomingPlayers)
local cleanUpGame = require(script.CleanUpGame)

return function()
	kickIncomingPlayers()
	Players.CharacterAutoLoads = false

	cleanUpGame()
end