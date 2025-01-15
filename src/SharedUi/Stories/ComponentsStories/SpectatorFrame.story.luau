--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local SpectatorBarUi = require(game.ReplicatedStorage.SharedUi.Components.SpectatorFrame)

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(SpectatorBarUi, {
            Text = "@USERNAME",

            LeftBarClick = function()
                --Swap Person
            end,
            RightBarClick = function()
                --Swap Person
            end
        }, {}))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story