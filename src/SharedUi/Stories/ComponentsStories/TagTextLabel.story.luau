--!strict
local React = require(game.ReplicatedStorage.Packages.React)
local FolderNet = require(game.ReplicatedStorage.Packages.FolderNet)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)

local Quest5v2TagVisible = FolderNet.GetBindableEvent("Quest5v2", "TagUiVisible")
local TagTextLabelUi = require(game.ReplicatedStorage.SharedUi.Components.TagTextLabel)

type uiTagTextLabelProps = {
    OnClick: () -> (),
}

local story = {
    render = function(props)
        local root = ReactRoblox.createRoot(props.target)
        root:render(React.createElement(TagTextLabelUi, {
            OnClick = function(time: string) 
                print("Clickaroo test!")
                task.wait(1)
                Quest5v2TagVisible:Fire(true)
            end 
        }))

        task.spawn(function()
            task.wait(0.25)
            Quest5v2TagVisible:Fire(true)
        end)

       return function() -- Cleanup your story here
            root:unmount()
       end
    end
}

return story