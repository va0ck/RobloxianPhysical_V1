--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local FailedGame = FolderNet.GetRemoteEvent("GAME", "FAILED")
local ADDPOINTS_DATASTORE = FolderNet.GetBindableEvent("DATASTORE", "ADDPOINTS")

--Modules
local eliminationMessages = require(script.Parent.Parent.Settings.EliminationMessages)
local A_QUESTCOUNT = require(ServerScriptService.QuestHandler.Quests.A_QUESTCOUNT)

--MainFunction
return function(player: Player)
	task.delay(2, function()
		local message = eliminationMessages[math.random(1, #eliminationMessages)]
		FailedGame:FireClient(player, message, A_QUESTCOUNT.CURRENT_COUNT * 10)
		ADDPOINTS_DATASTORE:Fire(player, (A_QUESTCOUNT.CURRENT_COUNT * 10))
	end)
end