--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EXAMPLES_FOLDER = ReplicatedStorage.SharedUi.Stories.Examples

local storybook = {
    name = "Examples",
    storyRoots = {
        EXAMPLES_FOLDER,
    },
 }
 
 return storybook