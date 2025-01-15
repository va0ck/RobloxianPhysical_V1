--!strict
--Settings
local LobbyPlaceId = 94222366715596

--Services
local Players = game:GetService("Players")
local SafeTeleport = require(game.ReplicatedStorage.SharedModules.SafeTeleport)


return function()
	Players.PlayerAdded:Connect(function(player)
		local success, _ = SafeTeleport(LobbyPlaceId, {player})
		
		if not success then
			player:Kick("The game has already started, please rejoin another server.")
		end
	end)
end