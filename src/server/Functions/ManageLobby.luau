--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--[[Modules]]
local Settings = script.Parent.Parent.Settings
local lobbyTime = require(Settings.LobbyTime)

--[[Connection]]
local scriptConnection = nil::RBXScriptConnection?

return function()
	print("Starting the lobby...")

	local startTime = os.time()
	local endTime = startTime + lobbyTime
	-- Function to handle a player joining the lobby
	local function handlePlayer(player: Player)
		-- Wait for character to load
		if not player.Character then
			player.CharacterAdded:Wait()
		end

		-- Start the timer for this player
		Remotes.StartTopTimer:FireClient(player, endTime)
		print(string.format("Player %s has joined the lobby.", player.Name))
	end

	-- Handle existing players
	for _, player in pairs(Players:GetPlayers()) do
		handlePlayer(player)
	end

	-- Handle new players joining during lobby
	scriptConnection = Players.PlayerAdded:Connect(handlePlayer)
	task.wait(lobbyTime)

	-- Clean up connection
	if scriptConnection then
		scriptConnection:Disconnect()
		scriptConnection = nil
	end

	print("Game is starting.")
end