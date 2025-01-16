--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local SharedUi = ReplicatedStorage:WaitForChild("SharedUi")
local FailedScreen = require(SharedUi.Components.FailScreenUi)
local SpectateScreen = require(SharedUi.Components.SpectatorFrame)

local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local FailedGame = FolderNet.GetRemoteEvent("GAME", "FAILED")

--Spectate Ui
local function spectateUi()
    local newHandle = Instance.new("ScreenGui")
    newHandle.Name = "SpectateUi"
    newHandle.IgnoreGuiInset = true
    newHandle.Parent = Players.LocalPlayer.PlayerGui

    local mountUi = ReactRoblox.createRoot(newHandle)
    mountUi:render(React.createElement(SpectateScreen, {
    }))
end

--Main Recieve
FailedGame.OnClientEvent:Connect(function(eliminationMsg :string)
    local newHandle = Instance.new("ScreenGui")
    newHandle.Name = "FailScreenUi"
    newHandle.IgnoreGuiInset = true
    newHandle.Parent = Players.LocalPlayer.PlayerGui

    local failMountUi = ReactRoblox.createRoot(newHandle)
    failMountUi:render(React.createElement(FailedScreen, {
        SpectateEvent = function()
            spectateUi()
            
            --Unmount when SpectateEvent happens.
            task.delay(5, function()
                failMountUi:unmount()
            end)
        end
    }))
end)