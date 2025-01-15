--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local FailedGame = FolderNet.GetRemoteEvent("GAME", "FAILED")

--Modules
local eliminationMessages = require(script.Parent.Parent.Settings.EliminationMessages)

--MainFunction
return function(player: Player)
	task.delay(2, function()
		local message = eliminationMessages[math.random(1, #eliminationMessages)]
		FailedGame:FireClient(player, message)
	end)
end