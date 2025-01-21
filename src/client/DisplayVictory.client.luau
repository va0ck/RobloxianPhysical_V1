--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local SharedUi = ReplicatedStorage:WaitForChild("SharedUi")
local VictoryScreen = require(SharedUi.Components.VictoryScreenUI)

ReplicatedStorage.Remotes.DisplayVictory.OnClientEvent:Connect(function(rewardedPoints: number)
    local newHandle = Instance.new("ScreenGui")
    newHandle.Name = "VictoryScreenUi"
    newHandle.IgnoreGuiInset = true
    newHandle.Parent = Players.LocalPlayer.PlayerGui

    print(`C | WIN POINTS: {rewardedPoints}`)

    local victoryMountUi = ReactRoblox.createRoot(newHandle)
    victoryMountUi:render(React.createElement(VictoryScreen, {
        RewardValue = rewardedPoints,
    }))
end)