--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local ScrollNumberLabel = require(game.ReplicatedStorage.SharedUi.Components.ScrollNumberLabel)

type numberScrollProps = {
    NumDigits: IntValue,
    VALUE: IntValue,

    Position: UDim2,
    AnchorPoint: Vector2,
    Size: UDim2,

    Font: Font,
    TextColor3: Color3,
}

local controls = {
    Value = 5,
 } 

local story = {
    react = React,
    reactRoblox = ReactRoblox,
    controls = controls,
    story = function(props)
        return React.createElement(ScrollNumberLabel, {
            Position = UDim2.fromScale(0.5,0.5),
            AnchorPoint = Vector2.new(0.5,0.5),
            Size = UDim2.fromScale(0.7, 0.3),

            NumDigits = 3,
            Value = props.controls.Value,

            Font = Font.new("rbxasset://fonts/families/Oswald.json"),
            TextColor3 = Color3.new(1,1,1)
        })
    end
}

return story