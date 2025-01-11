--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local TargetBillboardUi = require(game.ReplicatedStorage.SharedUi.Components.TargetBillboard)

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.5, 0.5)
        }, {
            StoryFrame = React.createElement(TargetBillboardUi, {}, {})
        }))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story