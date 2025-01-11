--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local COMPONENTS_FOLDER = ReplicatedStorage.SharedUi.Stories.ComponentsStories

local storybook = {
    name = "Components",
    storyRoots = {
        COMPONENTS_FOLDER,
    },
 }
 
 return storybook