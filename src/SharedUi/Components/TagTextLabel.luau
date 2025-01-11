--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local React = require(game.ReplicatedStorage.Packages.React)
local FolderNet = require(game.ReplicatedStorage.Packages.FolderNet)
local ReactSpring = require(game.ReplicatedStorage.Packages.ReactSpring)

local Quest5v2TagVisible = FolderNet.GetBindableEvent("Quest5v2", "TagUiVisible")

local isStudioDev = game:GetService("RunService"):IsStudio()

type uiTagTextLabelProps = {
    OnClick: () -> (),
}

return function(props: uiTagTextLabelProps)
    local gradientOffset, setGradientOffset = React.useState(Vector2.new(-0.75, 0))
    local frameStyle, frameApi = ReactSpring.useSpring(function()
        return { 
            from = { Position = UDim2.fromScale(0.5, 1.1) },
            config = { mass = 1, tension = 500, friction = 50 },
        }
    end)

    React.useEffect(function()
        local gradientDistance = 0
        local gradientSecondsPerCycle = 3
        local gradientSpeed = 1 / gradientSecondsPerCycle

        local scriptConnection = nil ::RBXScriptConnection?
        scriptConnection = Quest5v2TagVisible.Event:Connect(function(visibleStatus: boolean)
            if visibleStatus then
                frameApi.start({to = { Position = UDim2.fromScale(0.5, 0.95) }})
            else
                frameApi.start({to = { Position = UDim2.fromScale(0.5, 1.1) }})
            end
        end)

        scriptConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            gradientDistance += deltaTime * gradientSpeed
            gradientDistance = gradientDistance % 1
            setGradientOffset(Vector2.new(gradientDistance*1.75-0.75, 0))
        end)

        --UserInputService doesn't work with Story, so reset code isn't included. :|
        scriptConnection = UserInputService.InputBegan:Connect(function(inputObject :InputObject)
            if inputObject.UserInputType == Enum.UserInputType.Keyboard then
                if inputObject.KeyCode == Enum.KeyCode.E then
                    --Code to handle.
                    frameApi.start({to = { Position = UDim2.fromScale(0.5, 1.1) }})
                    
                    if not isStudioDev then
                        FolderNet.GetRemoteEvent("Quest5v2", "TaggedTarget"):FireServer()
                    end
                end
            end
        end)

        --This is for StoryPlugin to reset back to orgin.
        if isStudioDev then
            frameApi.start({to = { Position = UDim2.fromScale(0.5, 0.95) }})
        end

        return function()
            if scriptConnection then
                scriptConnection:Disconnect()
                scriptConnection = nil
            end
        end
    end, {})

    return React.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = frameStyle.Position,

        Size = UDim2.fromScale(0.9, 0.1),
        BackgroundTransparency = 1
    },{
        UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
            AspectRatio = 9
        }),

        TagTextLabel = React.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),

            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,

            Text = "PRESS [E] OR CLICK THIS TEXT TO TAG!",
            TextScaled = true,
            TextColor3 = Color3.new(1,1,1),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold),

            [React.Event.Activated] = function()
                frameApi.start({ to = { Position = UDim2.fromScale(0.5, 1.1) } })
                props.OnClick()
            end
        }, {
            UIStroke = React.createElement("UIStroke",{
                Thickness = 2
            }),
            TextUIGradient = React.createElement("UIGradient", {
                Offset = gradientOffset,
                Rotation = 45,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.25, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(0.415686, 0.764706, 1.000000)),
                    ColorSequenceKeypoint.new(0.75, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                }),
            })
        })
    })
end
