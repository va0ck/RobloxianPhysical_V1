local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

ReplicatedStorage.Remotes.DisplayVictory.OnClientEvent:Connect(function()
    local victoryImage = playerGui.MainUI.VictoryImage
    
    -- Set initial size
    victoryImage.Size = UDim2.new(0, 0, 0, 0)
    victoryImage.Visible = true
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        0.5, -- Duration
        Enum.EasingStyle.Back, -- Easing style for a "pop" effect
        Enum.EasingDirection.Out -- Easing direction
    )
    
    -- Create and play the tween
    local tween = TweenService:Create(victoryImage, tweenInfo, {
        Size = UDim2.new(1, 0, 1, 0) -- Final full size
    })
    tween:Play()
end)