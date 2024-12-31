local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Keep track of current timer coroutine

local function startCountdown(timerText, endTime)
    local timeLeft = endTime - os.time()
    local timeLabel = timerText:FindFirstChild("Time") or timerText
    
    -- Create new timer coroutine
    task.spawn(function()
        while timeLeft > 0 do
            -- Update time text
            timeLabel.Text = timeLeft
            
            -- Create tweens for rotation and transparency
            if timerText.Name == "Timer" then -- Only animate main timer, not top timer
                local rotationTween = TweenService:Create(timeLabel, 
                    TweenInfo.new(0.5, Enum.EasingStyle.Bounce), 
                    {Rotation = 360}
                )
                local transparencyTween = TweenService:Create(timeLabel,
                    TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                    {TextTransparency = 0.5}
                )
                
                -- Play tweens
                rotationTween:Play()
                transparencyTween:Play()
                
                -- Reset properties after tween
                task.delay(0.5, function()
                    timeLabel.Rotation = 0
                    timeLabel.TextTransparency = 0
                end)
            end
            
            -- Flash red when time is low
            if timeLeft <= 10 then
                timeLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                timeLabel.TextTransparency = (timeLeft % 2 == 0) and 0.5 or 0
            end
            
            task.wait(1)
            timeLeft -= 1
        end
        
        -- Reset when done
        timeLabel.Text = ""
        timeLabel.Visible = false
        timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timeLabel.TextTransparency = 0
        timeLabel.Rotation = 0
    end)
end

ReplicatedStorage.Remotes.StartTimer.OnClientEvent:Connect(function(endTime)
    local timerText = playerGui.MainUI.Timer
    timerText.Visible = true
    startCountdown(timerText, endTime)
end)

ReplicatedStorage.Remotes.StartTopTimer.OnClientEvent:Connect(function(endTime)
    local timerText = playerGui.MainUI.TopTimer
    timerText.Visible = true
    startCountdown(timerText, endTime)
end)