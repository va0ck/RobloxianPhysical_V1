local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local AvatarThumbnailModule = require(ReplicatedStorage.SharedModules.AvatarThumbnail)

local REPickMember = FolderNet.GetRemoteEvent("TeamPick", "PickMember")
local REPickMemberTimer = FolderNet.GetRemoteEvent("TeamPick", "PickMemberTimer")

local MemberPickUI = ReplicatedStorage.Assets.UI.MemberPick

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer.PlayerGui

local _scriptTimerConnection = nil :: RBXScriptConnection?
local _scriptConnections = nil :: RBXScriptConnection?

REPickMemberTimer.OnClientEvent:Connect(function(endTime)
    local TeamPickUI = playerGui.MainUI.TeamPickUI

    --Clears last timer.
    if _scriptTimerConnection then
        _scriptTimerConnection:Disconnect()
        _scriptTimerConnection = nil

        TeamPickUI.TimeLeft.Text = ""
    end

    --Starts Timer
    local timeLeft = endTime
    _scriptTimerConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if (os.time() >= endTime) then
            _scriptTimerConnection:Disconnect()
            _scriptTimerConnection = nil
            return
        end
        
        if TeamPickUI and TeamPickUI:FindFirstChild("TimeLeft") then
            TeamPickUI.TimeLeft.Text = string.format("Time Left: %01d", math.ceil(timeLeft))
        end

        timeLeft = endTime - os.time()
    end)
end)

REPickMember.OnClientEvent:Connect(function(availablePlayers)
    local TeamPickUI = playerGui.MainUI.TeamPickUI
    local ScrollingFrame = TeamPickUI.ScrollingFrame

    --Clear existing UI elements and connections.
    TeamPickUI.Visible = false
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    if _scriptConnections then
        _scriptConnections:Disconnect()
        _scriptConnections = nil
    end

    --Doesn't show if no avaliablePlayers.
    if #availablePlayers <= 0 then
        return
    end

    --Setups availablePlayers.
    TeamPickUI.Visible = true
    for _, availablePlayer in pairs(availablePlayers) do
        local memberPlayer = Players:GetPlayerByUserId(availablePlayer.userId)
        local memberUI = MemberPickUI:Clone()
        memberUI.Parent = ScrollingFrame

        -- Set up name
        local MemberName = memberUI:FindFirstChild("MemberName") ::TextLabel
        if MemberName then
            MemberName.Text = memberPlayer.Name
        end

        -- Set up avatar
        local MemberAvatar = memberUI:FindFirstChild("ProfilePicture") ::ImageLabel
        if MemberAvatar then
            MemberAvatar.Image = AvatarThumbnailModule(availablePlayer.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end
        
        -- Set up button click
        local pickButton = memberUI:FindFirstChild("PickButton") ::TextButton
        if pickButton then
            _scriptConnections = pickButton.MouseButton1Click:Connect(function()
                REPickMember:FireServer(availablePlayer.userId)
                TeamPickUI.Visible = false
            end)
        end
    end
end)