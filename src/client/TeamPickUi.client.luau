local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local MemberPickUI = ReplicatedStorage.Assets.UI.MemberPick

local PickMemberFunc = Remotes.PickMember

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer.PlayerGui

PickMemberFunc.OnClientInvoke = function(pickTimeout, availablePlayers)
    local TeamPickUI = playerGui.MainUI.TeamPickUI
    local ScrollingFrame = TeamPickUI.ScrollingFrame
    TeamPickUI.Visible = true
    
    -- Clear existing UI elements
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local selectedPlayer = nil
    
    -- Add UI for each available player
    for _, availablePlayer in pairs(availablePlayers) do
        local memberPlayer = Players:GetPlayerByUserId(availablePlayer.userId)
        local memberUI = MemberPickUI:Clone()
        memberUI.Parent = ScrollingFrame

        -- Set up name
        local MemberName = memberUI:FindFirstChild("MemberName")
        if MemberName then
            MemberName.Text = memberPlayer.Name
        end

        -- Set up avatar
        local MemberAvatar = memberUI:FindFirstChild("MemberAvatar")
        if MemberAvatar then
            MemberAvatar.Image = Players:GetUserThumbnailAsync(availablePlayer.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end
        
        -- Set up button click
        local pickButton = memberUI:FindFirstChild("PickButton")
        if pickButton then
            pickButton.MouseButton1Click:Connect(function()
                selectedPlayer = availablePlayer.userId
                TeamPickUI.Visible = false
            end)
        end
    end
    
    -- Update timer
    local timeLeft = pickTimeout
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not TeamPickUI.Visible then
            connection:Disconnect()
            return
        end
        
        TeamPickUI.TimeLeft.Text = string.format("Time Left: %d", math.ceil(timeLeft))
        timeLeft = timeLeft - game:GetService("RunService").Heartbeat:Wait()
        
        if timeLeft <= 0 then
            TeamPickUI.Visible = false
            connection:Disconnect()
        end
    end)
    
    -- Wait for selection or timeout
    local startTime = os.time()
    while TeamPickUI.Visible and os.time() - startTime < pickTimeout do
        task.wait()
    end
    
    TeamPickUI.Visible = false
    return selectedPlayer
end