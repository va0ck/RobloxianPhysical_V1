--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local e = React.createElement

type uiFailButton = {
    Text: string,
    PrimaryColor: Color3,
    TextColor: Color3,
    ImageIcon: string,

    AnchorPoint: Vector2,
    Position: UDim2,
    Size: UDim2,

    OnClick: () -> (),
}

return function(props: uiFailButton)

    return e("TextButton", {
        AnchorPoint = props.AnchorPoint,
        Position = props.Position,
        
        Size = props.Size,
        BackgroundColor3 = props.PrimaryColor,
        BorderSizePixel = 0,

        Text = "",
        TextScaled = true,

        [React.Event.Activated] = function()
            props.OnClick()
        end
    }, {
        UIAspectRatio = e("UIAspectRatioConstraint", {
            AspectRatio = 3.5,
        }),
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0.1, 0)
        }),
        UIStroke = e("UIStroke", {
            Thickness = 3,
            Transparency = 0.75,
        }),

        ImageIcon = e("ImageLabel", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.fromScale(0.05, 0.5),

            Size = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,

            Image = props.ImageIcon,
        }, {
            UIAspectRatioImgIcon = e("UIAspectRatioConstraint")
        }),

        TextLabelFrame = e("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.fromScale(0.95, 0.5),

            Size = UDim2.fromScale(0.7, 0.5),
            BackgroundTransparency = 1,
            TextScaled = true,

            TextColor3 = props.TextColor,
            FontFace = Font.new("rbxasset://fonts/families/RobotoCondensed.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic),

            Text = props.Text,
        }, {
            TextUIStroke = e("UIStroke", {
                Thickness = 1.5,
                Transparency = 0.5
            })
        })
    })
end
