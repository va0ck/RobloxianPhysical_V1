--!strict
local Players = game:GetService("Players")

return function()
	-- Destroy existing characters
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			player.Character:Destroy()
		end
	end
end