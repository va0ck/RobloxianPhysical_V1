--!strict
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)

return function()
    local gradientOffset, setGradientOffset = React.useState(Vector2.new(-0.75, 0))
    local imgPointerStyle, imgPointerApi = ReactSpring.useSpring(function()
        return { Position = UDim2.fromScale(0.5, -0.1) }
    end)

    React.useEffect(function()
        local gradientDistance = 0
        local gradientSecondsPerCycle = 3
        local gradientSpeed = 1 / gradientSecondsPerCycle

        local imgPosTimer = 0
        local imgPosTrigger = false
        
        local scriptConnection = nil ::RBXScriptConnection?
        scriptConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            gradientDistance += deltaTime * gradientSpeed
            gradientDistance = gradientDistance % 1
            setGradientOffset(Vector2.new(gradientDistance*1.75-0.75, 0))
        end)
        scriptConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            imgPosTimer += deltaTime

            if imgPosTimer >= 2 and (not imgPosTrigger) then
                imgPosTrigger = true

                imgPointerApi.start({ to = { Position = UDim2.fromScale(0.5, 0.25) } })
                task.wait(1)
                imgPointerApi.start({ to = { Position = UDim2.fromScale(0.5, -0.1) } })

                imgPosTimer = 0
                imgPosTrigger = false
            end
        end)

        return function()
            if scriptConnection then
                scriptConnection:Disconnect()
                scriptConnection = nil
            end
        end
    end,{})

    return React.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,
    }, {
        UIListLayout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder
        }),

        TargetTextLabel = React.createElement("TextLabel", {
            LayoutOrder = 1,

            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            --Pos can't be set due to UIListLayout.

            Size = UDim2.fromScale(1, 0.75),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold),

            Text = "TARGET",
            TextScaled = true,
            TextColor3 = Color3.new(1,1,1),
        }, {
            TextUIStroke = React.createElement("UIStroke", {
                Thickness = 3,
            }),

            TextUIGradient = React.createElement("UIGradient", {
                Offset = gradientOffset,
                Rotation = 45,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.25, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(1,0.25,0.25)),
                    ColorSequenceKeypoint.new(0.75, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                }),
            })
        }),

        PointerFrame = React.createElement("Frame",{
            LayoutOrder = 2,

            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromScale(1, 0.5),
            BackgroundTransparency = 1,
        }, {
            PointerImageLabel = React.createElement("ImageLabel", {
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = imgPointerStyle.Position,
                Size = UDim2.fromScale(1, 1),

                BackgroundTransparency = 1,

                Image = "rbxassetid://16368985219",
                ImageColor3 = Color3.new(1,0.25,0.25)
            }, {
                UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 2,
                    AspectType = Enum.AspectType.FitWithinMaxSize
                })
            })
        })
    })
end
