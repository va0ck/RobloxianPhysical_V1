--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages.React)
local FolderNet = require(Packages.FolderNet)
local ReactRoblox = require(Packages.ReactRoblox)

local ActivateTagRE = FolderNet.GetRemoteEvent("Quest5v2", "ActivateTag")
local Quest5v2TagVisible = FolderNet.GetBindableEvent("Quest5v2", "TagUiVisible")
local Quest5v2TaggedTarget = FolderNet.GetRemoteEvent("Quest5v2", "TaggedTarget")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local TagSettings = require(SharedModules.TagSettings)

local SharedUi = ReplicatedStorage:WaitForChild("SharedUi"):WaitForChild("Components")
local TagTextLabel = require(SharedUi.TagTextLabel)
local TargetBillboard = require(SharedUi.TargetBillboard)

local localPlayer = Players.LocalPlayer

--DYNAMIC_VARS
local scriptConnection = nil::RBXScriptConnection?
local highlightTable = {} :: {Highlight}

local rootBillboardTable = {}
local billboardTable = {}

local ifMadeTagGui = false
local rootScreenGuiTable = {}
local screenGuiTable = {}

ActivateTagRE.OnClientEvent:Connect(function(targetModel: Model)
    --ClearConnection
    if scriptConnection then
        scriptConnection:Disconnect()
        scriptConnection = nil
    end
    --ClearTable
    for _,v in pairs(highlightTable) do
        if v and v:IsA("Highlight") then
            v:Destroy()
        end
    end
    --Clear GuiBillboards
    for _,v in pairs(rootBillboardTable) do
        v:unmount()
    end
    for _,v in pairs(billboardTable) do
        v:Destroy()
    end

    --At the end of the round, send no value.
    if not targetModel then
        --Cleanup ReactUi & ScreenGui
        for _,v in pairs(rootScreenGuiTable) do
            v:unmount()
        end
        for _,v in pairs(screenGuiTable) do
            v:Destroy()
        end

        return
    end

    --Setup prompt Ui.
    if (not ifMadeTagGui) then
        ifMadeTagGui = true

        local screenGuiHandle = Instance.new("ScreenGui")
        screenGuiHandle.Name = "TagPromptGui"
        screenGuiHandle.Parent = localPlayer.PlayerGui

        local rootScreenGui = ReactRoblox.createRoot(screenGuiHandle)
        rootScreenGui:render(React.createElement(TagTextLabel, {
            OnClick = function(time: string)
                print(`TAGGED PLAYER WITH CLICK!`)
                Quest5v2TaggedTarget:FireServer()
            end
        }))

        table.insert(rootScreenGuiTable, rootScreenGui)
        table.insert(screenGuiTable, screenGuiHandle)
    end

    local targetHrp = targetModel:FindFirstChild("HumanoidRootPart") ::BasePart
    assert(targetHrp, "Target Hitbox doesn't exist!")
    local localPlrHrp = localPlayer.Character:FindFirstChild("HumanoidRootPart") ::BasePart
    assert(localPlrHrp, "Local player hitbox doesn't exist!")

    if targetModel and targetHrp and localPlrHrp then
        local instanceHighlight = Instance.new("Highlight")
        instanceHighlight.FillColor = TagSettings.TargetHighlightFill
        instanceHighlight.OutlineColor = TagSettings.TargetHighlightOutline
        instanceHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        instanceHighlight.Parent = targetModel

        local billboardScreen = Instance.new("BillboardGui")
        billboardScreen.LightInfluence = 0
        billboardScreen.Size = UDim2.fromScale(5, 4)
        billboardScreen.StudsOffsetWorldSpace = Vector3.new(0,5,0)
        billboardScreen.AlwaysOnTop = true
        billboardScreen.Name = `Target{targetModel.Name}BillboardGui`
        billboardScreen.Parent = localPlayer.PlayerGui
        billboardScreen.Adornee = targetHrp

        local rootBillboardScreen = ReactRoblox.createRoot(billboardScreen)
        rootBillboardScreen:render(React.createElement(TargetBillboard))

        table.insert(rootBillboardTable, rootBillboardScreen)
        table.insert(billboardTable, billboardScreen)

        local guiOpen = false
        scriptConnection = RunService.Heartbeat:Connect(function()
            local targetDist = (targetHrp.Position - localPlrHrp.Position).Magnitude

            if targetDist <= TagSettings.TargetPromptDistance and (not guiOpen) then
                guiOpen = true

                --OpenGui
                Quest5v2TagVisible:Fire(true)
            elseif targetDist > TagSettings.TargetPromptDistance and guiOpen then
                guiOpen = false

                --CloseGui
                Quest5v2TagVisible:Fire(false)
            end
        end)
    end
end)