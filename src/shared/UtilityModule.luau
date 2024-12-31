local Utilities = {}

type TreadmillConfig = {
	width: number,
	height: number,
	center: Vector3
}

function Utilities:SetQuestNumber(currentQuest: number, maxQuests: number)
	-- add a simple if then else statement to set the current quest number accordingly
	if currentQuest <= maxQuests then
		return currentQuest + 1, false -- false for more quests to come in the future
	else
		-- This means that all quests have finished; no more quests!
		return currentQuest, true -- return the current quest and true for the last quest
	end
end

return Utilities
