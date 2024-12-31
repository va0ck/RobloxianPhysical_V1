--!strict
--Settings
local ANCHOR_ROOTPART = false
local MAX_ATTEMPTS = 20

--Maps
local TeamPickMap = workspace.TeamPick

--Modules
local PlayerModule = require(script.Parent.Parent.Parent.OOP.PlayerObject)
local playersTable = require(script.Parent.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Parent.Tables).teamsTable

return function()
	for i, teamInfo in pairs(teamsTable) do
		local teamLeader = PlayerModule.GetPlayerObj(teamInfo.leader, playersTable)
		if teamLeader then
			local rblxPlayer = teamLeader.player
			rblxPlayer:LoadCharacter()
			
			local attempts = 0
			local rblxCharacter = rblxPlayer.Character
			repeat
				attempts += 1
				task.wait(0.1)
			until rblxCharacter or attempts >= MAX_ATTEMPTS
			
			if rblxCharacter then
				local humanoid = rblxCharacter:FindFirstChildOfClass("Humanoid")
				local rootPart = rblxCharacter:WaitForChild("HumanoidRootPart")
				
				local attempts2 = 0
				repeat
					attempts2 += 1
					task.wait(0.1)
				until (humanoid and rootPart:IsA("BasePart")) or attempts2 >= MAX_ATTEMPTS
				
				if humanoid and rootPart:IsA("BasePart") then
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0
					rootPart.Anchored = ANCHOR_ROOTPART
				end
			end

			local leaderSpot = TeamPickMap.LeaderSpots:FindFirstChild("Leader" .. i)
			local spawnPart = leaderSpot:FindFirstChild("SpawnPart")
			if leaderSpot and spawnPart and rblxCharacter then
				rblxCharacter:PivotTo(spawnPart.CFrame)
			end
		end
	end

	local losersPlaced = 0
	for _, plrInfo in pairs(playersTable) do
		if not plrInfo.isEliminated and not plrInfo:IsLeader(teamsTable) then
			local rblxPlayer = plrInfo.player
			rblxPlayer:LoadCharacter()
			
			local attempts = 0
			local rblxCharacter = rblxPlayer.Character
			repeat
				attempts += 1
				task.wait(0.1)
			until rblxCharacter or attempts >= MAX_ATTEMPTS
			
			if rblxCharacter then
				local humanoid = rblxCharacter:FindFirstChildOfClass("Humanoid")
				local rootPart = rblxCharacter:FindFirstChild("HumanoidRootPart")
				
				local attempts2 = 0
				repeat
					attempts2 += 1
					task.wait(0.1)
				until (humanoid and rootPart and rootPart:IsA("BasePart")) or attempts2 >= MAX_ATTEMPTS
				
				if humanoid and rootPart and rootPart:IsA("BasePart") then
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0
					rootPart.Anchored = ANCHOR_ROOTPART
				end
			end

			losersPlaced += 1

			local loserSpot = TeamPickMap.LoserSpots:FindFirstChild("Loser" .. losersPlaced)
			if loserSpot then
				if rblxCharacter then
					rblxCharacter:PivotTo(loserSpot.CFrame + Vector3.new(0, 5, 0))
				end
			end
		end
	end
end