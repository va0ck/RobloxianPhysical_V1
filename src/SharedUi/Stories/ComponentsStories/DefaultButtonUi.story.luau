--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local DefaultButtonUi = require(game.ReplicatedStorage.SharedUi.Components.DefaultButton)


local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.5, 0.5)
        }, {
            StoryFrame = React.createElement(DefaultButtonUi, {
                Text = "I'M A BUTTON! :3",
                ImageIcon = "rbxassetid://170940873",
                PrimaryColor = Color3.fromRGB(0, 255, 64),
                TextColor = Color3.new(1,1,1),

                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.5, 0.5),

                OnClick = function()
                end
            }, {})
        }))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story