--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)

local LOBBY_ID = 94222366715596
local SafeTeleport = require(game.ReplicatedStorage.SharedModules.SafeTeleport)

local e = React.createElement
local DefaultButton = require(script.Parent.DefaultButton)
local RewardScrollLabel = require(game.ReplicatedStorage.SharedUi.Components.RewardScroll)

return function(props)
    local transparencyOffset, setTransparencyOffset = React.useState(Vector2.new(2,0))


    --Animations Springs
    local victoryLogoStyle, victoryLogoApi = ReactSpring.useSpring(function()
        return {
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), 
        }
    end)
    local victoryButtonStyle, victoryButtonApi = ReactSpring.useSpring(function()
        return {
            Position = UDim2.fromScale(0.5, 1.5),
        }
    end)

    React.useEffect(function()
        local victoryLogoConnection = nil ::RBXScriptConnection?
        local victoryButtonConnection = nil ::RBXScriptConnection?
        local _swipeConnection = nil ::RBXScriptConnection?

        --Move FailLogo Upwards and Tiny.
        local victoryLogoTimer = 0
        local victoryLogoTrigger = false
        victoryLogoConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            victoryLogoTimer += deltaTime

            if victoryLogoTimer >= 1 and not victoryLogoTrigger then
                victoryLogoTrigger = true

                victoryLogoApi.start({
                    Size = UDim2.fromScale(0.3, 0.3),
                })

                task.wait(0.1)
                victoryLogoApi.start({
                    Position = UDim2.fromScale(0.5, 0.15), 
                })

                if victoryLogoConnection then
                    victoryLogoConnection:Disconnect()
                    victoryLogoConnection = nil
                end
            end
        end)

        --Moving Transparency Gradient
        local gradientDistance = 0
        local gradientSecondsPerCycle = 0.5
        local gradientSpeed = 1 / gradientSecondsPerCycle
        _swipeConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            gradientDistance += deltaTime * gradientSpeed
            setTransparencyOffset(Vector2.new(-gradientDistance*1.75+1, 0))
            
            if gradientDistance >= 1.5 and _swipeConnection then
                _swipeConnection:Disconnect()
                _swipeConnection = nil
            end
        end)

        --Moving buttons upwards.
        local victoryButtonDistance = 0
        victoryButtonConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            victoryButtonDistance += deltaTime
            
            if victoryButtonDistance >= 1 and victoryButtonConnection then
                victoryButtonApi.start({
                    Position = UDim2.fromScale(0.5, 0.95),
                })

                victoryButtonConnection:Disconnect()
                victoryButtonConnection = nil
            end
        end)

        return function()
            if victoryLogoConnection then
                victoryLogoConnection:Disconnect()
                victoryLogoConnection = nil
            end
            if _swipeConnection then
                _swipeConnection:Disconnect()
                _swipeConnection = nil
            end
            if victoryButtonConnection then
                victoryButtonConnection:Disconnect()
                victoryButtonConnection = nil
            end
        end
    end, {})


    return e("Frame", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0
    }, {
        TransparencyGradient = e("UIGradient", {
            Rotation = 45,
            Offset = transparencyOffset,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0.5),
            })
        }),

        VictoryLogoFrame = e("Frame", {
            Size = victoryLogoStyle.Size,
            Position = victoryLogoStyle.Position,
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1
        }, {
            UIAspectRatio = e("UIAspectRatioConstraint", {
                AspectRatio = 1.75,
            }),
            VictoryLogoElement = e("ImageLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,

                Image = "rbxassetid://111398776321964",
            }, {
                VictoryTransparencyGradient = e("UIGradient", {
                    Rotation = 45,
                    Offset = transparencyOffset,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                }),
            })
        }),
        RewardFrame = React.createElement(RewardScrollLabel, {
            Position = UDim2.fromScale(0.5,0.5),
            AnchorPoint = Vector2.new(0.5,0.5),
            Size = UDim2.fromScale(0.4, 0.825),

            NumDigits = 3,
            delayTime = 1.5,
            Value = props.RewardValue,

            Font = Font.new("rbxasset://fonts/families/Oswald.json"),
            TextColor3 = Color3.new(1,1,1)
        }),

        HomeButton = e(DefaultButton, {
            AnchorPoint = Vector2.new(0.5,1),
            Position = victoryButtonStyle.Position,
            Size = UDim2.fromScale(0.2, 0.2),

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
