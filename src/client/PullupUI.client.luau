local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local touchGui = playerGui:WaitForChild("TouchGui", 1)
local camera = Workspace.CurrentCamera

-- Variables for slider logic
local isDragging = false
local lastPosition = "left"
local canScore = true
local isTouchDevice = UserInputService.TouchEnabled

local pullUpAnimation = "rbxassetid://119917715517193"

-- Function to disable mobile controls
local function setMobileControlsEnabled(enabled)
    if not isTouchDevice then return end
    
    -- Disable jump button and backpack
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, enabled)
    
    -- Find and disable mobile buttons
    if touchGui then
        for _, button in ipairs(touchGui:GetDescendants()) do
            if button:IsA("GuiButton") or button:IsA("ImageButton") then
                button.Active = enabled
                button.Selectable = enabled
            end
        end
        
        -- Specifically handle jump and movement controls
        local jumpButton = touchGui:FindFirstChild("JumpButton", true)
        local thumbstick = touchGui:FindFirstChild("ThumbstickFrame", true)
        
        if jumpButton then
            jumpButton.Visible = enabled
        end
        if thumbstick then
            thumbstick.Visible = enabled
        end
    end
end

ReplicatedStorage.Remotes.EnablePullupUI.OnClientEvent:Connect(function(timeout)
    local pullupFrame = playerGui.MainUI.PullupUI
    local slideCircle = pullupFrame.SlideCircle
    pullupFrame.Visible = true
    lastPosition = "left"
    
    -- Set up camera
    local cameraPart = Workspace:WaitForChild("Quest5V3"):WaitForChild("CameraPart")
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = cameraPart.CFrame
    
    -- Handle character animations
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        local animator = humanoid and humanoid:FindFirstChild("Animator")
        
        if humanoid and animator then
            -- Disable default animations
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- Stop all current animations
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0) -- Stop immediately with 0 fade time
            end
            
            -- Load and play pullup animation
            local animation = Instance.new("Animation")
            animation.AnimationId = pullUpAnimation
            local animTrack = animator:LoadAnimation(animation)
            animTrack:Play(0.1) -- Play with a small fade time
            animTrack.Looped = true -- Ensure the animation loops
            
            -- Store the track for cleanup
            local function cleanup()
                -- Re-enable all states
                for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                    humanoid:SetStateEnabled(state, true)
                end
                
                if animTrack.IsPlaying then
                    animTrack:Stop(0.1)
                end
            end
            
            -- Clean up when the UI is hidden
            pullupFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if not pullupFrame.Visible then
                    cleanup()
                end
            end)
        end
    end
    
    -- Function to handle scoring
    local function tryScore(relativeX)
        if not canScore then return end
        
        if lastPosition == "left" and relativeX > 0.8 then
            lastPosition = "right"
            canScore = false
            
            -- Visual feedback
            slideCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            task.delay(0.2, function()
                slideCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                canScore = true
            end)
            
            -- Update score on server
            local scores = ReplicatedStorage.Remotes.UpdatePullupCount:InvokeServer()
            pullupFrame.MyScore.Text = scores[1]
            pullupFrame.TeammateScore.Text = scores[2]
            
        elseif lastPosition == "right" and relativeX < 0.2 then
            lastPosition = "left"
            canScore = false
            
            -- Visual feedback
            slideCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            task.delay(0.2, function()
                slideCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                canScore = true
            end)
            
            -- Update score on server
            local scores = ReplicatedStorage.Remotes.UpdatePullupCount:InvokeServer()
            pullupFrame.MyScore.Text = scores[1]
            pullupFrame.TeammateScore.Text = scores[2]
        end
    end
    
    -- Input handling
    local function handleInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end
    
    local function handleInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end
    
    -- Input connections
    slideCircle.InputBegan:Connect(handleInputBegan)
    slideCircle.InputEnded:Connect(handleInputEnded)
    
    -- Movement handling
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                          input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position
            local framePos = pullupFrame.AbsolutePosition
            local frameSize = pullupFrame.AbsoluteSize
            local circleSize = slideCircle.AbsoluteSize.X
            
            -- Calculate position
            local targetX = mousePos.X - framePos.X - (circleSize / 2)
            targetX = math.clamp(targetX, 0, frameSize.X - circleSize)
            
            -- Update position
            slideCircle.Position = UDim2.new(0, targetX, slideCircle.Position.Y.Scale, 0)
            
            -- Calculate relative position for scoring
            local relativeX = targetX / (frameSize.X - circleSize)
            tryScore(relativeX)
        end
    end)
    
    -- Disable controls
    if isTouchDevice then
        setMobileControlsEnabled(false)
    end

    -- Handle timer
    local timeLeft = timeout
    pullupFrame.Timer.Text = "Time: " .. timeLeft

    local function updateTimer()
        timeLeft -= 1
        pullupFrame.Timer.Text = "Time: " .. timeLeft

        if timeLeft <= 10 then
            pullupFrame.Timer.TextColor3 = Color3.fromRGB(255, 0, 0)
            pullupFrame.Timer.TextTransparency = (timeLeft % 2 == 0) and 0.5 or 0
        end

        if timeLeft <= 0 then
            if isTouchDevice then
                setMobileControlsEnabled(true)
            end
            pullupFrame.Visible = false
            camera.CameraType = Enum.CameraType.Custom
            return false
        end
        return true
    end

    -- Start timer loop
    task.spawn(function()
        while updateTimer() do
            task.wait(1)
        end
    end)
end)

-- Handle score updates from other players
ReplicatedStorage.Remotes.UpdatePullupScore.OnClientEvent:Connect(function(playerScore, teammateScore)
    local pullupFrame = playerGui.MainUI.PullupUI
    if pullupFrame.Visible then
        pullupFrame.TeammateScore.Text = teammateScore
        pullupFrame.MyScore.Text = playerScore
    end
end)