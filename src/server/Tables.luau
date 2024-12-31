--!strict
--[[
	Mainly placed into a module for other quests to be able
	to update the table and able to access the same table.
	
	Typecheck will also trasnfer over to scripts.
]]--

--Grabbing OOP Modules
local PlayerModule = require(script.Parent.OOP.PlayerObject)

--Types
type teamsTable = {
	leader: number,
	members: {number},
	name: string,
	color: BrickColor,
	
	isEliminated: boolean,
	eliminationTime: number|any,
	
	questData: {
		quest2Finished: boolean,
		quest2MembersReached: {number},
		quest2FinishTime: number|any,
		quest2ObjectsPlaced: number,
		
		quest3Finished: boolean,
		quest3FinishTime: number|any,
		
		quest4Score: number|any,
		quest4Finished: boolean,
		quest4FinishTime: number|any,
	}
}

--Main Tables
local scriptTables = {}

scriptTables.playersTable = {} :: {PlayerModule.PlayerObject}
scriptTables.teamsTable = {} :: {teamsTable}
scriptTables.lastStandingTeam = {} :: teamsTable

return scriptTables