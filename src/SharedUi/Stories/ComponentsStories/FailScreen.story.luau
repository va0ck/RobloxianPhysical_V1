--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local FailScreenUi = require(game.ReplicatedStorage.SharedUi.Components.FailScreenUi)

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(FailScreenUi, {
            SpectateEvent = function()
                --TempCode
            end
        }, {}))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story