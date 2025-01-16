--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FolderNet = require(game.ReplicatedStorage.Packages.FolderNet)
local TeleportLobby = FolderNet.GetRemoteEvent("GAME", "TELEPORT_LOBBY")

local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local currentCamera = workspace.CurrentCamera

local DefaultButton = require(script.Parent.DefaultButton)
local SpectatorBar = require(script.SpectatorBar)

type SpectatorFrameType = {
    Text: string,
}

return function(props: SpectatorFrameType)
    --Non-States
    local currentIndex, setCurrentIndex = React.useState(1)
    local playerList, setPlayerList = React.useState({})

    --States
    local currentUsername, setCurrentUsername = React.useState("@N/A")

    --Animations
    local homeButtonStyle, homeButtonApi = ReactSpring.useSpring(function()
        return {
            Position = UDim2.fromScale(0.75, -0.3),
        }
    end)

    -----------------------
    --//LOCAL FUNCTIONS//--
    -----------------------
    local function updatePlayers()
        local newPlayerList = {}

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(newPlayerList, plr.Name)
            end
        end
            
        setPlayerList(newPlayerList)
    end
    local function updateSpectator()
        local foundPlayer = Players:FindFirstChild(playerList[currentIndex]) ::Player

        if foundPlayer then
            currentCamera.CameraSubject = foundPlayer.Character
            return foundPlayer.Name
        end

        return "@N/A"
    end

    --Buttons Functions
    local function nextPlayer()
        updatePlayers()

        if currentIndex < #playerList then
            setCurrentIndex(currentIndex+1)
        else
            setCurrentIndex(1)
        end

        return updateSpectator()
    end
    local function lastPlayer()
        if currentIndex > 1 then
            setCurrentIndex(currentIndex-1)
        else
            setCurrentIndex(#playerList)
        end
        
        return updateSpectator()
    end

    --Run Once
    React.useEffect(function()
        homeButtonApi.start({
            Position = UDim2.fromScale(0.75, 0),
        })
    end,{})

    return e("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)
    }, {
        SpectatorBarUI = e(SpectatorBar, {
            Text = currentUsername,
            LeftClick = function()
                if RunService:IsStudio() then
                    print(`CAN'T RUN SPECTATE ON STUDIO CODE.`)
                    return
                end

                --Stuff
                updatePlayers()
                setCurrentUsername(nextPlayer())
            end,
            RightClick = function()
                if RunService:IsStudio() then
                    print(`CAN'T RUN SPECTATE ON STUDIO CODE.`)
                    return
                end

                --Stuff
                updatePlayers()
                setCurrentUsername(lastPlayer())
            end
        }),

        HomeButton = e(DefaultButton, {
            AnchorPoint = Vector2.new(0.5,0),
            Position = homeButtonStyle.Position,
            Size = UDim2.fromScale(0.15, 0.15),

            Text = "BACK TO LOBBY",
            ImageIcon = "rbxassetid://170940873",
            PrimaryColor = Color3.fromRGB(0, 255, 64),
            TextColor = Color3.new(1,1,1),

            OnClick = function()
                if not RunService:IsStudio() then
                    TeleportLobby:FireServer()
                else
                    print(`IN STUDIO CURRENTLY AND CANNOT TELEPORT.`)
                end
            end
        }),
    })
end
