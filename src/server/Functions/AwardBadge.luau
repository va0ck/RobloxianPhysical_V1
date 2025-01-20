--!strict
local BadgeService = game:GetService("BadgeService")

---------------------------
--//AVOID GIVING BADGES//--
---------------------------
local AVOID_BADGE_GIVING = {
	844029031, --va0ck [I just don't like badges on my profile lol.]
}

-------------------------------
--//MAIN FUNCTION TO RETURN//--
-------------------------------
return function(player :Player, badgeId :number)
	if table.find(AVOID_BADGE_GIVING, player.UserId) then
		return
	end
	
	-- Fetch badge information
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local awardSuccess, result = pcall(function()
				return BadgeService:AwardBadge(player.UserId, badgeId)
			end)

			if not awardSuccess then
				-- the AwardBadge function threw an error
				warn("Error while awarding badge:", result)
			elseif not result then
				-- the AwardBadge function did not award a badge
				warn("Failed to award badge.")
			end
		end
	else
		warn("Error while fetching badge info: " .. badgeInfo)
	end
end
