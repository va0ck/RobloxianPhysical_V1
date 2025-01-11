--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local ExampleCounter = function()
    local count, setCount = React.useState(0)

    return React.createElement("TextButton", {
        Size = UDim2.fromScale(0.5, 0.125),
        TextScaled = true,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5,0.5),

        Text = string.format("Clicked %d times", count),
        -- Clicking the button updates the count, which re-renders the component
        [React.Event.Activated] = function()
            setCount(count + 1)
        end
    })
end

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(ExampleCounter, {}, {}))
 
       return function() -- Cleanup your story here
            root:unmount()
            
       end
    end
}

return story