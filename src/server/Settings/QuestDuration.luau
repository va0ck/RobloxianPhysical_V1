--!strict
--[[
	SKIP_TIME_DEV is a global skip for development.
]]--

return {
	Quest1 = (_G._RPQ_DEVTIME and 1) or 40,  -- 15s normal + 15s fast + 10s fastest
	TeamPick = (_G._RPQ_DEVTIME and 1) or 30, -- Max time for team pick before it becomes random.
	Quest2 = (_G._RPQ_DEVTIME and 1) or 120, -- 2 minutes for complex building and coordination
	Quest3 = (_G._RPQ_DEVTIME and 1) or 120, -- 3 minutes for ball movement challenge
	Quest4 = (_G._RPQ_DEVTIME and 1) or 100,  -- 2.5 minutes for competitive sand bag collection
	Quest5V3 = (_G._RPQ_DEVTIME and 30) or 105 
} :: {[string]: number}