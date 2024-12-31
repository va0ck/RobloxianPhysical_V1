--!strict
--[[
	Added Typecheck so it'll be compatiable with !strict in other scripts.
]]--
local Player = {}
Player.__index = Player

-- Constructor for new player
function Player.new(robloxPlayer :Player, index: number)
    local self = setmetatable({}, Player)
    
    -- Basic info
    self.userId = robloxPlayer.UserId ::number
    self.name = robloxPlayer.Name ::string
    self.player = robloxPlayer ::Player
    self.playerIndex = index ::number
    
    -- Game state
    self.isEliminated = false ::boolean
    self.eliminationTime = nil ::number|any
    self.finalPlacement = nil ::number|any
    
    -- Team info
    self.team = nil ::string|any
    self.finalTeamPlacement = nil ::number|any
    
    -- Quest specific
    self.questData = {
        quest1Eliminated = false ::boolean,
        quest1EliminationTime = nil ::number|any,
    }
    
	return self
end

--Typecheck support for tables.
export type PlayerObject = typeof(Player.new(...))

function Player.GetPlayerObj(userId, playersTable)
    for _, player in pairs(playersTable) do
        if player.userId == userId then
            return player
        end
    end
    return nil ::any
end

-- Player Methods
function Player:Eliminate()
	if self.isEliminated then 
		return 
	end
    
    self.isEliminated = true
    self.eliminationTime = os.time()
    
	-- Clean up character if exists
	local playerCheck = self.player ::Player
	if playerCheck and playerCheck.Character then
		playerCheck.Character:Destroy()
    end
    
    return self.finalPlacement
end

function Player:GetFinalPlacement(allPlayers :{PlayerObject})
    if not self.isEliminated then 
        -- If this player isn't eliminated, they're tied for first with other non-eliminated players
        local nonEliminatedCount = 0
        for _, player in pairs(allPlayers) do
            if not player.isEliminated then
                nonEliminatedCount = nonEliminatedCount + 1
            end
        end
        self.finalPlacement = 1
        return self.finalPlacement
    end
    
	local eliminatedPlayers = {} :: {PlayerObject}
    local nonEliminatedCount = 0
    for _, player in pairs(allPlayers) do
        if player.isEliminated then
            table.insert(eliminatedPlayers, player)
        else
            nonEliminatedCount = nonEliminatedCount + 1
        end
    end
    
    -- Sort players by elimination time (earlier eliminations = worse placement)
    table.sort(eliminatedPlayers, function(a, b)
        return a.eliminationTime > b.eliminationTime
    end)
    
    -- Find this player's position in the sorted list
    -- Add nonEliminatedCount to account for players still in game (they're all in first place)
    for i, player in ipairs(eliminatedPlayers) do
        if player.userId == self.userId then
            self.finalPlacement = nonEliminatedCount + (#eliminatedPlayers - i + 1)
            return self.finalPlacement
        end
    end
    
    return nil ::any
end

function Player:EliminateQuest1()
    if not self.questData.quest1Eliminated then
        self.questData.quest1Eliminated = true
        self.questData.quest1EliminationTime = os.time()
        
		-- Clean up character if exists
		local playerCheck = self.player ::Player
		if playerCheck and playerCheck.Character then
			playerCheck.Character:Destroy()
        end
    end
end

function Player:GetQuest1Placement(allPlayers)
    if not self.questData.quest1Eliminated then 
        -- If this player isn't eliminated, they're tied for first
        local nonEliminatedCount = 0
        for _, player in pairs(allPlayers) do
            if not player.questData.quest1Eliminated then
                nonEliminatedCount = nonEliminatedCount + 1
            end
        end
        return 1
    end
    
	local eliminatedPlayers = {} :: {PlayerObject}
    local nonEliminatedCount = 0
    for _, player in pairs(allPlayers) do
        if player.questData.quest1Eliminated then
            table.insert(eliminatedPlayers, player)
        else
            nonEliminatedCount = nonEliminatedCount + 1
        end
    end
    
    -- Sort players by elimination time
    table.sort(eliminatedPlayers, function(a, b)
        return a.questData.quest1EliminationTime > b.questData.quest1EliminationTime
    end)
    
    -- Find this player's position
    for i, player in ipairs(eliminatedPlayers) do
        if player.userId == self.userId then
            return nonEliminatedCount + (#eliminatedPlayers - i + 1)
        end
    end
    
    return nil ::any
end

function Player:IsLeader(teamsTable)
    for _, team in pairs(teamsTable) do
        if team.leader == self.userId then
            return true
        end
    end
    return false
end

function Player:Despawn()
	local ifPlayerExist = self.player ::Player
	
	if ifPlayerExist and ifPlayerExist.Character then
		ifPlayerExist.Character:Destroy()
    end
end

return Player