--!strict
-- Quest 2 runner:
-- - Kicks off the camera transition and drops teams into their lanes
-- - Handles pickups (Block/Circle), placements, and finish line logic
-- - Starts a global timer, waits for finish/timeout, then ranks and eliminates


local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Quest2Map = workspace.Quest2

local Quest2Sound: Sound = SoundService.Quest2
local WhiteSound: Sound = SoundService.Whistle

local BlockTool = ReplicatedStorage.Tools.Block
local CircleTool = ReplicatedStorage.Tools.Circle

local SettingsFolder = script.Parent.Parent.Settings
local transitionTime = require(SettingsFolder.TransitionTime)
local questsDuration = require(SettingsFolder.QuestDuration)
local questImages = require(SettingsFolder.QuestImages)
local questMessages = require(SettingsFolder.QuestMessages)

local PlayerModule = require(script.Parent.Parent.OOP.PlayerObject)
local respawnToObby = require(script.Parent.Parent.Functions).respawnToObby
local playersTable = require(script.Parent.Parent.Tables).playersTable
local teamsTable = require(script.Parent.Parent.Tables).teamsTable
local _A_QUESTCOUNT = require(script.Parent.Parent.Quests.A_QUESTCOUNT)

return function()
	-- -------- helpers --------

	-- Tools: keep state deterministic (no stacking/equipped bypass).
	local function clearTools(player: Player)
		player.Backpack:ClearAllChildren()
		local char = player.Character
		if not char then return end
		for _, inst in ipairs(char:GetChildren()) do
			if inst:IsA("Tool") then inst:Destroy() end
		end
	end

	local function giveTool(player: Player, toolTemplate: Tool)
		local t = toolTemplate:Clone()
		t.Parent = player.Backpack
	end

	local function playerObjFor(player: Player)
		return PlayerModule.GetPlayerObj(player.UserId, playersTable)
	end

	local function isOnTeam(player: Player, teamName: string): boolean
		local obj = playerObjFor(player)
		return obj ~= nil and obj.team == teamName
	end

	-- Equipped tools live on the Character.
	local function hasTool(player: Player, toolName: string)
		for _, inst in ipairs(player.Backpack:GetChildren()) do
			if inst:IsA("Tool") and inst.Name == toolName then
				return true, inst
			end
		end
		local char = player.Character
		if char then
			for _, inst in ipairs(char:GetChildren()) do
				if inst:IsA("Tool") and inst.Name == toolName then
					return true, inst
				end
			end
		end
		return false, nil
	end

	-- ----- CFrame utilities -----

	-- Snap a position to a stud grid.
	local function snapToGrid(v: Vector3, grid: number): Vector3
		return Vector3.new(
			math.floor(v.X / grid + 0.5) * grid,
			math.floor(v.Y / grid + 0.5) * grid,
			math.floor(v.Z / grid + 0.5) * grid
		)
	end

	-- Forward vector orthogonal to a given up vector (avoid degenerate frames).
	local function orthonormalForward(up: Vector3, desiredForward: Vector3?): Vector3
		local f = (desiredForward or Vector3.zAxis)
		local proj = f - up * f:Dot(up)
		if proj.Magnitude < 1e-3 then
			proj = (math.abs(up:Dot(Vector3.xAxis)) < 0.99) and Vector3.xAxis or Vector3.zAxis
			proj = proj - up * proj:Dot(up)
		end
		return proj.Unit
	end

	-- Probe the true surface normal (sockets may be tilted).
	local function probeNormal(targetPart: BasePart, worldPoint: Vector3): Vector3
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { targetPart }
		local result = workspace:Raycast(worldPoint + Vector3.yAxis * 5, Vector3.new(0, -10, 0), params)
		if result and result.Instance == targetPart then
			return result.Normal.Unit
		end
		return Vector3.yAxis
	end

	-- Build a surface-aligned, grid-snapped frame for a socket part.
	local function surfaceAlignedCFrame(targetPart: BasePart, grid: number, laneForward: Vector3): CFrame
		local pos = snapToGrid(targetPart.Position, grid)
		local up = probeNormal(targetPart, pos)
		local fwd = orthonormalForward(up, laneForward)
		return CFrame.lookAt(pos, pos + fwd, up)
	end

	-- Deterministic animation (Heartbeat) with a simple ease-out.
	local function animateTo(part: BasePart, targetCF: CFrame, duration: number)
		local startCF = part.CFrame
		local t0 = os.clock()
		local t1 = t0 + duration
		while true do
			local now = os.clock()
			if now >= t1 then break end
			local alpha = (now - t0) / duration
			alpha = 1 - (1 - alpha) * (1 - alpha) -- easeOutQuad
			part.CFrame = startCF:Lerp(targetCF, alpha)
			RunService.Heartbeat:Wait()
		end
		part.CFrame = targetCF
	end

	-- Randomize within pad and orient player to lane forward.
	local function spawnAtRandomOriented(character: Model, spawnPart: BasePart)
		local size = spawnPart.Size
		local pos = spawnPart.Position
		local rx = pos.X + (math.random() - 0.5) * size.X
		local rz = pos.Z + (math.random() - 0.5) * size.Z
		local up = spawnPart.CFrame.UpVector
		local forward = orthonormalForward(up, spawnPart.CFrame.LookVector)
		local base = Vector3.new(rx, pos.Y + 3, rz)
		local cf = CFrame.lookAt(base, base + forward, up)
		character:PivotTo(cf)
	end

	-- Fire client transition once; then we wait for its duration.
	local function fireTransitionToAll()
		for _, plrInfo in pairs(playersTable) do
			local player = plrInfo.player
			if not player or plrInfo.isEliminated then continue end
			ReplicatedStorage.Remotes.CameraTransition:FireClient(
				player,
				Quest2Map,
				transitionTime.Quest2,
				questMessages.Quest2,
				questImages.Quest2
			)
		end
	end

	-- Generic pickup prompts (Block/Circle).
	local function initPickupPrompts(container: Instance, toolTemplate: Tool, actionText: string, objectText: string)
		for _, item in ipairs(container:GetChildren()) do
			if not item:IsA("BasePart") then continue end
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = actionText
			prompt.ObjectText = objectText
			prompt.HoldDuration = 0
			prompt.RequiresLineOfSight = false
			prompt.Parent = item

			prompt.Triggered:Connect(function(player: Player)
				clearTools(player)
				giveTool(player, toolTemplate)
			end)
		end
	end

	-- Placement prompts: animate, align to surface, snap to grid, then score.
	local function initPlacementPrompts(container: Instance, toolTemplate: Tool, actionText: string, maxDistance: number)
		for _, socket in ipairs(container:GetChildren()) do
			if not socket:IsA("BasePart") then continue end

			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = actionText
			prompt.ObjectText = "Building Spot"
			prompt.HoldDuration = 0
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = maxDistance
			prompt.Parent = socket

			prompt.Triggered:Connect(function(player: Player)
				local ok, toolInst = hasTool(player, toolTemplate.Name)
				if not ok or not toolInst then return end

				toolInst:Destroy()

				-- Make it visible and safe to animate.
				socket.CanCollide = false
				socket.Transparency = 0.25

				-- Try to infer a lane-forward from socket’s frame (fallback to +Z).
				local laneForward = socket.CFrame.LookVector
				if laneForward.Magnitude < 1e-3 then laneForward = Vector3.zAxis end

				-- Final aligned frame (grid = 1 stud; adjust if you use a different grid).
				local finalCF = surfaceAlignedCFrame(socket, 1, laneForward)

				-- Start from a drop pose with a small yaw offset.
				local startCF = finalCF * CFrame.new(0, 8, 0) * CFrame.Angles(0, math.rad(25 + math.random(-10, 10)), 0)
				socket.CFrame = startCF

				-- Fly-in + tiny settle.
				animateTo(socket, finalCF, 0.45)
				local overshoot = finalCF * CFrame.new(0, 0.15, 0)
				animateTo(socket, overshoot, 0.08)
				animateTo(socket, finalCF, 0.08)

				socket.CanCollide = true
				socket.Transparency = 0
				prompt:Destroy()

				-- Score through the player’s team binding (prevents cross-lane abuse).
				local pobj = playerObjFor(player)
				if pobj then
					for _, teamV2 in pairs(teamsTable) do
						if teamV2.name == pobj.team then
							teamV2.questData.quest2ObjectsPlaced += 1
							break
						end
					end
				end
			end)
		end
	end

	-- Finish line: counts active members only, then stamps finish time.
	local function initFinishLine(teamIndex: number, teamName: string, finishRoot: Instance)
		local finishPart = finishRoot:FindFirstChild("FinishPart") :: BasePart
		if not finishPart then return end
		local bb = finishPart:FindFirstChild("BillboardGui")
		local playersReachedText = bb and bb:FindFirstChild("PlayersReached")
		local team = teamsTable[teamIndex]
		if not team or not playersReachedText then return end

		local function refreshBillboard()
			(playersReachedText :: TextLabel).Text = string.format("%d/%d",
				#team.questData.quest2MembersReached,
				#team.members
			)
		end

		finishPart.Touched:Connect(function(hit: BasePart)
			local char = hit.Parent
			if not char or not char:FindFirstChildWhichIsA("Humanoid") then return end

			local plr = Players:GetPlayerFromCharacter(char)
			if not plr or not isOnTeam(plr, teamName) then return end

			for _, id in ipairs(team.questData.quest2MembersReached) do
				if id == plr.UserId then
					return
				end
			end

			table.insert(team.questData.quest2MembersReached, plr.UserId)
			refreshBillboard()

			local allReached = true
			for _, memberId in ipairs(team.members) do
				local m = PlayerModule.GetPlayerObj(memberId, playersTable)
				if m and m.player then
					local found = false
					for _, reachedId in ipairs(team.questData.quest2MembersReached) do
						if reachedId == memberId then
							found = true
							break
						end
					end
					if not found then
						allReached = false
						break
					end
				end
			end

			if allReached then
				team.questData.quest2Finished = true
				team.questData.quest2FinishTime = os.time()
				print(string.format("Team %s has completed Quest 2!", teamName))
			end
		end)

		refreshBillboard()
	end

	local function allTeamsFinishedOrEliminated(): boolean
		for _, team in pairs(teamsTable) do
			if not team.questData.quest2FinishTime and not team.isEliminated then
				return false
			end
		end
		return true
	end

	-- -------- boot quest --------

	Quest2Sound:Play()
	_A_QUESTCOUNT.CURRENT_COUNT = 2
	print("Starting Quest 2...")

	fireTransitionToAll()
	task.wait(transitionTime.Quest2)

	-- Cache once.
	local teamSpawns = Quest2Map.TeamSpawns
	local pickupAreas = Quest2Map.PickupAreas
	local blockPlacements = Quest2Map.BlockPlacements
	local finishLines = Quest2Map.FinishLines

	-- Per-team wiring
	for i, team in pairs(teamsTable) do
		-- Spawns + backstop.
		do
			local teamSpawn = teamSpawns:FindFirstChild("Team" .. i)
			if teamSpawn then
				local spawnPart = teamSpawn:FindFirstChild("SpawnPart") :: BasePart
				local spawnBackPart = teamSpawn:FindFirstChild("SpawnBackPart") :: BasePart
				if spawnPart and spawnBackPart then
					spawnBackPart.Touched:Connect(function(hit: BasePart)
						local char = hit.Parent
						if not char then return end
						local plr = Players:GetPlayerFromCharacter(char)
						if not plr then return end
						if isOnTeam(plr, team.name) then
							spawnAtRandomOriented(char, spawnPart)
						end
					end)

					for _, memberId in ipairs(team.members) do
						local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
						if memberObj and memberObj.player then
							memberObj.player:LoadCharacter()
							repeat task.wait() until memberObj.player.Character and memberObj.player.Character:FindFirstChild("HumanoidRootPart")
							if memberObj.player.Character then
								spawnAtRandomOriented(memberObj.player.Character, spawnPart)
							end
						end
					end
				end
			end
		end

		-- Pickups
		do
			local pickupArea = pickupAreas:FindFirstChild("PickupArea" .. i)
			if pickupArea then
				local pickupBlocks = pickupArea:FindFirstChild("Blocks")
				local pickupCircles = pickupArea:FindFirstChild("Circles")
				if pickupBlocks then
					initPickupPrompts(pickupBlocks, BlockTool, "Pick Up Block", "Building Block")
				end
				if pickupCircles then
					initPickupPrompts(pickupCircles, CircleTool, "Pick Up Circle", "Building Circle")
				end
			end
		end

		-- Placements (now animated/aligned)
		do
			local placementRoot = blockPlacements:FindFirstChild("Team" .. i .. "Blocks")
			if placementRoot then
				local blockPlace = placementRoot:FindFirstChild("BlockPlace")
				local circlePlace = placementRoot:FindFirstChild("CirclePlace")
				if blockPlace then
					initPlacementPrompts(blockPlace, BlockTool, "Place Block", 10)
				end
				if circlePlace then
					initPlacementPrompts(circlePlace, CircleTool, "Place Circle", 20)
				end
			end
		end

		-- Finish line
		do
			local finishRoot = finishLines:FindFirstChild("FinishTeam" .. i)
			if finishRoot then
				initFinishLine(i, team.name, finishRoot)
			end
		end
	end

	-- Global timer HUD
	local startTime = os.time()
	WhiteSound:Play()
	for _, plrInfo in pairs(playersTable) do
		local player = plrInfo.player
		if not player or plrInfo.isEliminated then continue end
		ReplicatedStorage.Remotes.StartTopTimer:FireClient(player, startTime + questsDuration.Quest2)
	end

	-- Wait for finish or timeout
	while not allTeamsFinishedOrEliminated() do
		if os.time() - startTime > questsDuration.Quest2 then
			break
		end
		task.wait(1)
	end

	-- -------- wrap up --------

	Quest2Sound:Stop()
	WhiteSound:Play()

	for _, teamInfo in pairs(teamsTable) do
		print(string.format("Team %s - Objects Placed: %d", teamInfo.name, teamInfo.questData.quest2ObjectsPlaced))
	end

	-- Rank by placements (desc)
	local sortedTeams = {}
	for _, t in pairs(teamsTable) do table.insert(sortedTeams, t) end
	table.sort(sortedTeams, function(a, b)
		return a.questData.quest2ObjectsPlaced > b.questData.quest2ObjectsPlaced
	end)

	local now = os.time()
	for rank, team in ipairs(sortedTeams) do
		-- Reset state for next quest.
		for _, memberId in ipairs(team.members) do
			local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
			if memberObj then
				memberObj:Despawn()
			end
		end

		-- Keep top 3, cut the rest.
		if rank > 3 then
			team.isEliminated = true
			team.eliminationTime = now
			for _, memberId in ipairs(team.members) do
				local memberObj = PlayerModule.GetPlayerObj(memberId, playersTable)
				if memberObj then
					memberObj.isEliminated = true
					memberObj.eliminationTime = now
					respawnToObby(memberObj.player)
				end
			end
			print(string.format("Team %s has been eliminated! (Objects Placed: %d)", team.name, team.questData.quest2ObjectsPlaced))
		else
			print(string.format("Team %s advances! (Objects Placed: %d)", team.name, team.questData.quest2ObjectsPlaced))
		end
	end

	-- Kill the top timer
	ReplicatedStorage.Remotes.StartTopTimer:FireAllClients(0)
end
