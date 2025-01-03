--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeTeleport = require(ReplicatedStorage.SharedModules.SafeTeleport)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local LobbyPlaceId = 94222366715596

--Modules
local eliminationMessages = require(script.Parent.Parent.Settings.EliminationMessages)

--MainFunction
return function(player: Player)
	task.delay(2, function()
		if not player.Character then
			player:LoadCharacter()
		end



		-- local message = eliminationMessages[math.random(1, #eliminationMessages)]
		-- Remotes.StartTopTimer:FireClient(player, os.time() + 30)
		-- task.wait(30)
		
		-- local success, _ = SafeTeleport(LobbyPlaceId, {player})
		-- if not success then
		-- 	player:Kick(message)
		-- end
	end)
end