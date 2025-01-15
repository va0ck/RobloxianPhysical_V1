--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LOBBY_ID = 94222366715596
local SafeTeleport = require(game.ReplicatedStorage.SharedModules.SafeTeleport)

local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local DefaultButton = require(script.Parent.DefaultButton)
local SpectatorBar = require(script.SpectatorBar)

type SpectatorFrameType = {
    Text: string,

    LeftBarClick: () -> (),
    RightBarClick: () -> (),
}

return function(props: SpectatorFrameType)
    --Animations
    local homeButtonStyle, homeButtonApi = ReactSpring.useSpring(function()
        return {
            Position = UDim2.fromScale(0.75, -0.3),
        }
    end)

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
            Text = props.Text,
            LeftClick = function()
                props.LeftBarClick()
            end,
            RightClick = function()
                props.RightBarClick()
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
                    SafeTeleport(LOBBY_ID, {Players.LocalPlayer}) 
                else
                    print(`IN STUDIO CURRENTLY AND CANNOT TELEPORT.`)
                end
            end
        }),
    })
end
