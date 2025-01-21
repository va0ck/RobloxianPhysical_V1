--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local ScrollNumberLabel = require(game.ReplicatedStorage.SharedUi.Components.ScrollNumberLabel)

return function(props)
    --States for coins going up.
    local currentCoinVal, setCurrentCoinVal = React.useState(0)

    --Spring Animations
    local frameStyle, frameApi = ReactSpring.useSpring(function()
        return { 
            from = { 
                iconFramePos = UDim2.fromScale(0, -0.5),
                coinsFramePos = UDim2.fromScale(1,1.5)
             },
            config = { mass = 0.5, tension = 750 }
        }
    end)
    
    --One time function.
    React.useEffect(function()
        local timerConnection = nil ::RBXScriptConnection?

        --Move FailLogo Upwards and Tiny.
        local timerTime = 0
        local timerTrigger = false
        timerConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            timerTime += deltaTime

            if timerTime >= props.delayTime and not timerTrigger then
                timerTrigger = true

                frameApi.start({
                    iconFramePos = UDim2.fromScale(0, 0.5),
                    coinsFramePos = UDim2.fromScale(1,0.5)
                })
                setCurrentCoinVal(props.Value)

                if timerConnection then
                    timerConnection:Disconnect()
                    timerConnection = nil
                end
            end
        end)

        return function()
            if timerConnection then
                timerConnection:Disconnect()
                timerConnection = nil
            end
        end
    end, {})


    --Content
    return e("Frame", {
        AnchorPoint = props.AnchorPoint,
        Position = props.Position,
        Size = props.Size,
        
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    },{
        AspectRatioUI = e("UIAspectRatioConstraint", {
            AspectRatio = 3,
        }),

        IconFrame = e("Frame", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = frameStyle.iconFramePos,
            Size = UDim2.fromScale(0.6, 1),
            BackgroundTransparency = 1,

        }, {
            IconTextLabel = e("TextLabel", {
                Position = UDim2.fromScale(1,0.5),
                AnchorPoint = Vector2.new(1,0.5),
                Size = UDim2.fromScale(0.775, 0.45),
                BackgroundTransparency = 1,

                Text = "COINS EARNED:",
                TextScaled = true,

                FontFace = props.Font,
                TextColor3 = props.TextColor3
            }),

            ImageIconLabel = e("ImageLabel", {
                Position = UDim2.fromScale(0,0.5),
                AnchorPoint = Vector2.new(0,0.5),
                Size = UDim2.fromScale(0.35, 0.35),
                BackgroundColor3 = Color3.new(0,0,0),
                BackgroundTransparency = 1,
    
                Image = "rbxassetid://74384487219502"
            }, {
                IconAspectRatioUI = e("UIAspectRatioConstraint", {
                    AspectRatio = 1,
                }),
            }),
        }),

        ScrollNum = e(ScrollNumberLabel, {
            Position = frameStyle.coinsFramePos,
            AnchorPoint = Vector2.new(1,0.5),
            Size = UDim2.fromScale(0.5, 1),

            NumDigits = props.NumDigits,
            Value = currentCoinVal,

            Font = props.Font,
            TextColor3 = props.TextColor3
        })
    })
end
