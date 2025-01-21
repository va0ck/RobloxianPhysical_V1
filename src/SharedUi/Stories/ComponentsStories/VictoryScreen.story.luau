--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local VictoryScreenUi = require(game.ReplicatedStorage.SharedUi.Components.VictoryScreenUI)

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(VictoryScreenUi, {
            RewardValue = 999
        }, {}))
 
       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story