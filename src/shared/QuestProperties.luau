-- -- SERVICES --
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- -- VARIABLES --
-- local cameraController = require(ReplicatedStorage.SharedModules.CameraController)

DEFAULT_CAMERA_PROPERTIES = {
	TWEEN_TIME = 1,
	EASING = Enum.EasingStyle.Quad,
	DIRECTION = Enum.EasingDirection.Out,
	DEFAULT_HEIGHT = 10,
	DEFAULT_DISTANCE = 20
}

local self = {
	BASE_QUEST_TAG_NAME = "Quest",
}
return self
