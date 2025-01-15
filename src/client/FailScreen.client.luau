--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local currentCamera = workspace.CurrentCamera
local currentIndex = 1
local playerList = {} :: {Player}

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local SharedUi = ReplicatedStorage:WaitForChild("SharedUi")
local FailedScreen = require(SharedUi.Components.FailScreenUi)
local SpectateScreen = require(SharedUi.Components.SpectatorFrame)

local FolderNet = require(ReplicatedStorage.Packages.FolderNet)
local FailedGame = FolderNet.GetRemoteEvent("GAME", "FAILED")

local currentUsername = "@N/A"

--updatePlayers List
local function updatePlayers()
    local newPlayerList = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            table.insert(newPlayerList, plr.Name)
        end
    end
        
    playerList = newPlayerList
end
local function updateSpectator()
    local foundPlayer = Players:FindFirstChild(playerList[currentIndex]) ::Player

    if foundPlayer then
        currentUsername = foundPlayer.Name
        currentCamera.CameraSubject = foundPlayer.Character
    end
end

--Buttons Functions
local function nextPlayer()
    if currentIndex < #playerList then
        currentIndex += 1
    else
        currentIndex = 1
    end
    updateSpectator()
end
local function lastPlayer()
    if currentIndex > 1 then
        currentIndex -= 1
    else
        currentIndex = #playerList
    end
    updateSpectator()
end

--Spectate Ui
local function spectateUi()
    updatePlayers()

    local newHandle = Instance.new("ScreenGui")
    newHandle.Name = "SpectateUi"
    newHandle.IgnoreGuiInset = true
    newHandle.Parent = Players.LocalPlayer.PlayerGui

    local mountUi = ReactRoblox.createRoot(newHandle)
    mountUi:render(React.createElement(SpectateScreen, {
        Text = currentUsername,

        LeftBarClick = function()
            nextPlayer()
        end,
        RightBarClick = function()
            lastPlayer()
        end
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