--!strict
local Players = game:GetService("Players")
local PLACEHOLDER_IMG = "rbxassetid://15859247590"

return function(userId: number, thumbType: Enum.ThumbnailType, thumbSize: Enum.ThumbnailSize)
	local imgContent, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	return (isReady and imgContent) or PLACEHOLDER_IMG
end