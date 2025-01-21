--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local RewardScrollLabel = require(game.ReplicatedStorage.SharedUi.Components.RewardScroll)

type rewardScrollProps = {
    NumDigits: IntValue,
    Value: IntValue,

    Position: UDim2,
    AnchorPoint: Vector2,
    Size: UDim2,

    Font: Font,
    TextColor3: Color3,
}

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(RewardScrollLabel, {
            Position = UDim2.fromScale(0.5,0.5),
            AnchorPoint = Vector2.new(0.5,0.5),
            Size = UDim2.fromScale(0.7, 0.825),

            NumDigits = 3,
            delayTime = 0,
            Value = 300,

            Font = Font.new("rbxasset://fonts/families/Oswald.json"),
            TextColor3 = Color3.new(1,1,1)
        }))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story