--!strict
local RunService = game:GetService("RunService")

local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)

local FolderNet = require(game.ReplicatedStorage.Packages.FolderNet)
local TeleportLobby = FolderNet.GetRemoteEvent("GAME", "TELEPORT_LOBBY")

local e = React.createElement
local FailLogo = require(script.FailLogo)
local DefaultButton = require(script.Parent.DefaultButton)
local RewardScrollLabel = require(game.ReplicatedStorage.SharedUi.Components.RewardScroll)

return function(props)
    local transparencyNumberSequence, setTransparencyNumberSequence = React.useState(
        NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.5),
    }))
    local transparencyRotation, setTransparencyRotation = React.useState(45) --Will be used for Spectate rotation switch swipe.
    local transparencyOffset, setTransparencyOffset = React.useState(Vector2.new(2,0))


    --Animations Springs
    local failLogoStyle, failLogoApi = ReactSpring.useSpring(function()
        return {
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), 
        }
    end)
    local failButtonStyle, failButtonApi = ReactSpring.useSpring(function()
        return {
            Position1 = UDim2.fromScale(0.39, 1.3),
            Position2 = UDim2.fromScale(0.61, 1.3)
        }
    end)
    local rewardFrameStyle, rewardFrameApi = ReactSpring.useSpring(function()
        return {
            Size = UDim2.fromScale(0.4, 0.825),
            Position = UDim2.fromScale(0.5,0.5),
        }
    end)


    React.useEffect(function()
        local failLogoConnection = nil ::RBXScriptConnection?
        local failButtonConnection = nil ::RBXScriptConnection?
        local _swipeConnection = nil ::RBXScriptConnection?

        --Move FailLogo Upwards and Tiny.
        local failLogoTimer = 0
        local failLogoTrigger = false
        failLogoConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            failLogoTimer += deltaTime

            if failLogoTimer >= 1.5 and not failLogoTrigger then
                failLogoTrigger = true

                failLogoApi.start({
                    Size = UDim2.fromScale(0.3, 0.3),
                })

                task.wait(0.1)
                failLogoApi.start({
                    Position = UDim2.fromScale(0.5, 0.15), 
                })

                if failLogoConnection then
                    failLogoConnection:Disconnect()
                    failLogoConnection = nil
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
        local failButtonDistance = 0
        failButtonConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            failButtonDistance += deltaTime
            
            if failButtonDistance >= 1.5 and failButtonConnection then
                failButtonApi.start({
                    Position1 = UDim2.fromScale(0.39, 0.95),
                    Position2 = UDim2.fromScale(0.61, 0.95)
                })

                failButtonConnection:Disconnect()
                failButtonConnection = nil
            end
        end)

        return function()
            if failLogoConnection then
                failLogoConnection:Disconnect()
                failLogoConnection = nil
            end
            if _swipeConnection then
                _swipeConnection:Disconnect()
                _swipeConnection = nil
            end
            if failButtonConnection then
                failButtonConnection:Disconnect()
                failButtonConnection = nil
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
            Rotation = transparencyRotation,
            Offset = transparencyOffset,
            Transparency = transparencyNumberSequence
        }),
        FailLogoFrame = e("Frame", {
            Size = failLogoStyle.Size,
            Position = failLogoStyle.Position,
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1
        }, {
            UIAspectRatio = e("UIAspectRatioConstraint", {
                AspectRatio = 2,
            }),
            FailLogoElement = e(FailLogo)
        }),
        RewardFrame = React.createElement(RewardScrollLabel, {
            Position = rewardFrameStyle.Position,
            AnchorPoint = Vector2.new(0.5,0.5),
            Size = rewardFrameStyle.Size,

            NumDigits = 3,
            delayTime = 2.0,
            Value = props.RewardValue,

            Font = Font.new("rbxasset://fonts/families/Oswald.json"),
            TextColor3 = Color3.new(1,1,1)
        }),

        HomeButton = e(DefaultButton, {
            AnchorPoint = Vector2.new(0.5,1),
            Position = failButtonStyle.Position2,
            Size = UDim2.fromScale(0.2, 0.2),

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
        SpectateButton = e(DefaultButton, {
            AnchorPoint = Vector2.new(0.5,1),
            Position = failButtonStyle.Position1,
            Size = UDim2.fromScale(0.2, 0.2),

            Text = "SPECTATE GAME",
            ImageIcon = "rbxassetid://13321848320",
            PrimaryColor = Color3.fromRGB(255, 105, 105),
            TextColor = Color3.new(1,1,1),

            OnClick = function()
                setTransparencyRotation(-45)
                setTransparencyOffset(Vector2.new(2*1.75+1, 0))
                setTransparencyNumberSequence(NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 1),
                }))
                failLogoApi.start({
                    Position = UDim2.fromScale(0.5, -0.3),
                    Size = UDim2.fromScale(0.05, 0.05),
                })
                failButtonApi.start({
                    Position1 = UDim2.fromScale(0.39, 1.3),
                    Position2 = UDim2.fromScale(0.61, 1.3)
                })
                rewardFrameApi.start({
                    Size = UDim2.fromScale(0.01, 0.01),
                    Position = UDim2.fromScale(-0.5, 0.5),
                })

                --Swipe Effect
                local swipeOutConnection = nil ::RBXScriptConnection?
                local gradientDistance = 0
                local gradientSecondsPerCycle = 0.5
                local gradientSpeed = 1 / gradientSecondsPerCycle
                swipeOutConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
                    gradientDistance += deltaTime * gradientSpeed
                    setTransparencyOffset(Vector2.new(-gradientDistance*1.75+1, 0))

                    if gradientDistance >= 1.5 and swipeOutConnection then
                        swipeOutConnection:Disconnect()
                        swipeOutConnection = nil
                    end
                end)

                --Send out a event to do Spectator Ui.
                props.SpectateEvent()
            end
        })
    })
end
