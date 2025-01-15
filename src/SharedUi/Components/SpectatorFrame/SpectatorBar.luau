--!strict
local RunService = game:GetService("RunService")

local React = require(game.ReplicatedStorage.Packages.React)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

type SpectatorBarType = {
    Text: string,

    LeftClick: () -> (),
    RightClick: () -> (),
}

return function(props: SpectatorBarType)
    local gradientOffset, setGradientOffset = React.useState(Vector2.new(-0.75, 0))

    --Spring Animations
    local spectatorFrameStyle, spectatorFrameApi = ReactSpring.useSpring(function()
        return {
            Position = UDim2.fromScale(0.5, 1.3),
        }
    end)

    --Runs once.
    React.useEffect(function()
        local _gradientConnection = nil ::RBXScriptConnection?

        --Spring Move Up
        spectatorFrameApi.start({
            Position = UDim2.fromScale(0.5, 0.95)
        })

        --GradientForeverRotation
        local gradientDistance = 0
        local gradientSecondsPerCycle = 3
        local gradientSpeed = 1 / gradientSecondsPerCycle
        _gradientConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            gradientDistance += deltaTime * gradientSpeed
            gradientDistance = gradientDistance % 1

            setGradientOffset(Vector2.new(gradientDistance*1.75-0.75, 0))
        end)


        return function()
            if _gradientConnection then
                _gradientConnection:Disconnect()
                _gradientConnection = nil
            end
        end
    end, {})

    return e("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = spectatorFrameStyle.Position,
        Size = UDim2.fromScale(0.95, 0.11),

        BackgroundTransparency = 1,
    }, {
        UIAspectRatio = e("UIAspectRatioConstraint", {
            AspectRatio = 8
        }),

        MainFrame = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),

            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.7, 1)
        }, {
            MainFrameUICorner = e("UICorner", {
                CornerRadius = UDim.new(0.1,0)
            }),
            MainFrameUIGradient = e("UIGradient", {
                Rotation = 45,
                Offset = gradientOffset,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0,150,255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,150,255)),
                    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0,150,255)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                })
            }),

            MainBackFrame = e("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(27,27,27),

                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.98, 0.9)
            }, {
                MainBackFrameUICorner = e("UICorner", {
                    CornerRadius = UDim.new(0.1,0)
                }),
                MainFrameTextLabel = e("TextLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,

                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.9, 0.65),

                    Text = props.Text,
                    TextScaled = true,
                    TextColor3 = Color3.new(1,1,1),
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold)
                })
            }),
        }),

        LeftButton = e("TextButton", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.fromScale(0, 0.5),

            BackgroundColor3 = Color3.fromRGB(27, 27, 27),
            Size = UDim2.fromScale(1,0.8),

            Text = "[<]",
            TextScaled = true,
            TextColor3 = Color3.new(1,1,1),

            FontFace = Font.new(
                "rbxasset://fonts/families/Roboto.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),

            [React.Event.Activated] = function()
                props.LeftClick()
            end
        }, {
            LeftUIAspectRatio = e("UIAspectRatioConstraint"),
            LeftUICorner = e("UICorner", {
                CornerRadius = UDim.new(0.1,0)
            })
        }),

        RightButton = e("TextButton", {
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.fromScale(1, 0.5),

            BackgroundColor3 = Color3.fromRGB(27, 27, 27),
            Size = UDim2.fromScale(1,0.8),

            Text = "[>]",
            TextScaled = true,
            TextColor3 = Color3.new(1,1,1),

            FontFace = Font.new(
                "rbxasset://fonts/families/Roboto.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),

            [React.Event.Activated] = function()
                props.RightClick()
            end
        }, {
            RightUIAspectRatio = e("UIAspectRatioConstraint"),
            RightUICorner = e("UICorner", {
                CornerRadius = UDim.new(0.1,0)
            })
        })
    })
end
