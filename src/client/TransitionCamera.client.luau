--SETTINGS
local DEBUG_PRINT = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local EXCLUDE_MOVEAGAIN_TABLE = {
	workspace.TeamPick,
}

-- Debug function to print CFrame info
local function debugCFrame(msg, cf)
	if DEBUG_PRINT then
		print(msg, "Position:", cf.Position, "LookVector:", cf.LookVector)
	end
end

local function printf(...)
	if DEBUG_PRINT then
		print(...)
	end
end

ReplicatedStorage.Remotes.CameraTransition.OnClientEvent:Connect(function(map, transitionTime, messages, transitionImage)
	printf("Starting camera transition for map:", map.Name)
    
    local transitionText = playerGui.MainUI.TransitionText
    local transitionImageFrame = playerGui.MainUI.TransitionImage
    transitionText.Visible = true
    transitionText.Text = ""
    
    -- Handle transition image if provided
    if transitionImage then
        transitionImageFrame.Image = transitionImage
        transitionImageFrame.Visible = true
        transitionImageFrame.ImageTransparency = 0
        
        -- Fade out after 3 seconds
        task.delay(3, function()
            local fadeTime = 0.5
            local startTime = tick()
            
            -- Fade out animation
            while tick() - startTime < fadeTime do
                local alpha = (tick() - startTime) / fadeTime
                transitionImageFrame.ImageTransparency = alpha
                task.wait()
            end
            
            transitionImageFrame.Visible = false
        end)
    end
    
    -- Find the map in workspace if it's a string
    if typeof(map) == "string" then
        map = workspace:WaitForChild(map, 5)
        if not map then
            warn("Could not find map:", map)
            return
        end
    end
    
    local transitionParts = map:WaitForChild("Transitions", 5)
    if not transitionParts then 
        warn("No transitions folder found in map:", map.Name)
        return 
    end
	
	printf("Found transitions folder")
    
    -- Calculate total distance of all transitions
    local totalDistance = 0
    local transitions = {}
    local i = 1
    
    while true do
        local startPart = transitionParts:FindFirstChild("Transition" .. i .. "V1")
        local endPart = transitionParts:FindFirstChild("Transition" .. i .. "V2")
        
		if not startPart or not endPart then 
			printf("No more transitions found at index:", i)
            break 
        end
		
		printf("Found transition pair", i, "Start:", startPart.Name, "End:", endPart.Name)
		printf("Start Position:", startPart.Position, "End Position:", endPart.Position)
        
        local distance = (endPart.Position - startPart.Position).Magnitude
        totalDistance += distance
        
        table.insert(transitions, {
            start = startPart,
            finish = endPart,
            distance = distance
        })
        
        i += 1
    end
    
    if #transitions == 0 then
        warn("No transitions found in map:", map.Name)
        return
    end
	
	printf("Found", #transitions, "transitions. Total distance:", totalDistance)
    
    -- Calculate total text length
    local totalTextLength = 0
    for _, msg in ipairs(messages) do
        totalTextLength += #msg
    end
    
    -- Calculate time per character, using less time for text but maintaining total duration
    local timePerChar = (transitionTime * 0.9) / (totalTextLength + (#messages * 4)) -- Use 70% of time, more spacing between messages
	
	printf("Starting camera transitions. Total time:", transitionTime)
    
    -- Store original camera settings
    local originalCFrame = camera.CFrame
    debugCFrame("Original camera CFrame:", originalCFrame)
    
    -- Get character and humanoid if they exist
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    -- Disable character control during transition if character exists
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.AutoRotate = false
    end
    
    -- Start camera transitions
    task.spawn(function()
        -- Force camera type change
        camera.CameraType = Enum.CameraType.Scriptable
        
        -- Make sure camera changes take effect
        task.wait()
        
		for _, transition in ipairs(transitions) do
			printf("Starting transition from", transition.start.Name, "to", transition.finish.Name)
            
            -- Get start and end CFrames from the parts
            local startCF = transition.start.CFrame
            local endCF = transition.finish.CFrame
            
            debugCFrame("Start CFrame:", startCF)
            debugCFrame("End CFrame:", endCF)
            
            -- Set initial camera position
            camera.CFrame = startCF
            task.wait()
            
            -- Create and play tween
            local tweenInfo = TweenInfo.new(
                (transition.distance / totalDistance) * transitionTime,
                Enum.EasingStyle.Linear
            )
            
            local tween = TweenService:Create(camera, tweenInfo, {
                CFrame = endCF
            })
			
			printf("Starting tween from", startCF.Position, "to", endCF.Position)
			
            tween:Play()
			tween.Completed:Wait()
			
			printf("Completed tween")
        end
		
		printf("All transitions complete")
		
		
		local MAX_ATTEMPTS = 30
		local attempts = 0
		repeat
			task.wait(0.1)
			attempts += 1
		until player.Character or attempts >= MAX_ATTEMPTS
		
		camera.CFrame = originalCFrame
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        
        -- Re-enable character control if character exists
		if humanoid and not table.find(EXCLUDE_MOVEAGAIN_TABLE, map) then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.AutoRotate = true
        end
    end)
    
    -- Start text transitions
    task.spawn(function()
        for i, message in ipairs(messages) do
            local displayedText = ""
            
            -- Type out the message
            for j = 1, #message do
                displayedText = displayedText .. message:sub(j,j)
                transitionText.Text = displayedText
                task.wait(timePerChar)
            end
            
            -- Wait between messages if not the last message
            if i < #messages then
                task.wait(timePerChar * 2) -- Use consistent timing
                transitionText.Text = ""
            end
        end
        
        -- Clear text at the end
        task.wait(timePerChar * 2)
        transitionText.Text = ""
        transitionText.Visible = false
    end)
end)