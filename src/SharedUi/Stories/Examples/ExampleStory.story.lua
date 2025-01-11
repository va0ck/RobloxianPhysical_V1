--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local ExampleStory = function()
    --Logic


    --Content
    return React.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.5,0.5)

    }, {
        React.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.75,0.15),

            TextScaled = true,
            Text = "Example Story!",

            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1,1,1),
            FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
        }, {
            React.createElement("UIStroke", {
                Thickness = 3,
                Transparency = 0.5
            })
        })
    })
end

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(ExampleStory, {}, {}))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story