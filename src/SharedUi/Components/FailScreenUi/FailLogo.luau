--!strict
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local React = require(game.ReplicatedStorage.Packages.React)

--I'm just adding this in at this point since why not.
--The modulescript isn't really needed now since this is over 80 LINES AND 800 LINES OF CODE.
--Soo, possibly depreciated in the future if we get a new design.
local LOGO_FAILS = {
    [1] = "rbxassetid://77376409063031",
    [2] = "rbxassetid://108261704078268",
    [3] = "rbxassetid://98044271005183",
    [4] = "rbxassetid://93295468844518",
    [5] = "rbxassetid://84840984427700",
    [6] = "rbxassetid://133772194545518",
    [7] = "rbxassetid://96372584889483",
    [8] = "rbxassetid://97974985964678",
    [9] = "rbxassetid://131640440351639",
    [10] = "rbxassetid://81009100316712",
    [11] = "rbxassetid://85255577321032",
    [12] = "rbxassetid://103773807842818",
    [13] = "rbxassetid://92730012574991",
    [14] = "rbxassetid://114501964819855",
    [15] = "rbxassetid://138065111548514",
    [16] = "rbxassetid://88418252944778",
    [17] = "rbxassetid://81914621463506",
    [18] = "rbxassetid://119777055348208",
    [19] = "rbxassetid://109071675311837",
    [20] = "rbxassetid://83482415421520",
    [21] = "rbxassetid://84254465322536",
    [22] = "rbxassetid://138880525790937",
    [23] = "rbxassetid://72305226691121",
    [24] = "rbxassetid://108286420971820",
    [25] = "rbxassetid://91054292309837",
    [26] = "rbxassetid://85075970951736",
    [27] = "rbxassetid://123230592509163",
    [28] = "rbxassetid://94906936891315",
    [29] = "rbxassetid://122657880651007"
}

local e = React.createElement

local callback = function(assetId, assetFetchStatus)
    if (assetFetchStatus == Enum.AssetFetchStatus.Failure) then
        print(`FAILED TO FETCH IMAGE: {assetId}`)
    end
end

return function()
    local gradientRotation = -15
    local transparencyOffset, setTransparencyOffset = React.useState(Vector2.new(1,0))

    --[[
        Preferably, we would use a for loop to change images.
        BUT ROBLOX MAKES THE IMAGES BLINK WHEN IT'S ALREADY
        PRELOADED THOUGH IN A SINGLE IMAGE??

        SOO, WE NEED TO DO MULTIPLE IMAGES.
    ]]--
    local visible1, setVisible1 = React.useState(true);
    local visible2, setVisible2 = React.useState(true);
    local visible3, setVisible3 = React.useState(true);
    local visible4, setVisible4 = React.useState(true);
    local visible5, setVisible5 = React.useState(true);
    local visible6, setVisible6 = React.useState(true);
    local visible7, setVisible7 = React.useState(true);
    local visible8, setVisible8 = React.useState(true);
    local visible9, setVisible9 = React.useState(true);
    local visible10, setVisible10 = React.useState(true);
    local visible11, setVisible11 = React.useState(true);
    local visible12, setVisible12 = React.useState(true);
    local visible13, setVisible13 = React.useState(true);
    local visible14, setVisible14 = React.useState(true);
    local visible15, setVisible15 = React.useState(true);
    local visible16, setVisible16 = React.useState(true);
    local visible17, setVisible17 = React.useState(true);
    local visible18, setVisible18 = React.useState(true);
    local visible19, setVisible19 = React.useState(true);
    local visible20, setVisible20 = React.useState(true);
    local visible21, setVisible21 = React.useState(true);
    local visible22, setVisible22 = React.useState(true);
    local visible23, setVisible23 = React.useState(true);
    local visible24, setVisible24 = React.useState(true);
    local visible25, setVisible25 = React.useState(true);
    local visible26, setVisible26 = React.useState(true);
    local visible27, setVisible27 = React.useState(true);
    local visible28, setVisible28 = React.useState(true);
    local visible29, setVisible29 = React.useState(true);


    --Run once useEffect.
    React.useEffect(function()
        local _swipeConnection = nil ::RBXScriptConnection?
        local _imageConnection = nil ::RBXScriptConnection?

        --Loads images in.
        ContentProvider:PreloadAsync(LOGO_FAILS, callback)
        task.wait(0.25)

        --Have images visible so they load. e.e
        --then make images invisible to do frame by frame.
        setVisible2(false)
        setVisible3(false)
        setVisible4(false)
        setVisible5(false)
        setVisible6(false)
        setVisible7(false)
        setVisible8(false)
        setVisible9(false)
        setVisible10(false)
        setVisible11(false)
        setVisible12(false)
        setVisible13(false)
        setVisible14(false)
        setVisible15(false)
        setVisible16(false)
        setVisible17(false)
        setVisible18(false)
        setVisible19(false)
        setVisible20(false)
        setVisible21(false)
        setVisible22(false)
        setVisible23(false)
        setVisible24(false)
        setVisible25(false)
        setVisible26(false)
        setVisible27(false)
        setVisible28(false)
        setVisible29(false)

        --Change Images
        local FRAMEPER_SEC = (60 / 17)/100
        local loadingImg = false
        local currentTime = 0
        local indexImg = 1

        _imageConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            currentTime += deltaTime

            if (not loadingImg) and currentTime >= FRAMEPER_SEC and indexImg < table.maxn(LOGO_FAILS) then
                loadingImg = true
                indexImg += 1
                
                --[[
                    Sorry for the if and elseif code. 🙏
                    Very swag code that doesn't blink though. 😎
                ]]--
                if indexImg == 2 then
                    setVisible1(false)
                    setVisible2(true)
                elseif indexImg == 3 then
                    setVisible2(false)
                    setVisible3(true)
                elseif indexImg == 4 then
                    setVisible3(false)
                    setVisible4(true)
                elseif indexImg == 5 then
                    setVisible4(false)
                    setVisible5(true)
                elseif indexImg == 6 then
                    setVisible5(false)
                    setVisible6(true)
                elseif indexImg == 7 then
                    setVisible6(false)
                    setVisible7(true)
                elseif indexImg == 8 then
                    setVisible7(false)
                    setVisible8(true)
                elseif indexImg == 9 then
                    setVisible8(false)
                    setVisible9(true)
                elseif indexImg == 10 then
                    setVisible9(false)
                    setVisible10(true)
                elseif indexImg == 11 then
                    setVisible10(false)
                    setVisible11(true)
                elseif indexImg == 12 then
                    setVisible11(false)
                    setVisible12(true)
                elseif indexImg == 13 then
                    setVisible12(false)
                    setVisible13(true)
                elseif indexImg == 14 then
                    setVisible13(false)
                    setVisible14(true)
                elseif indexImg == 15 then
                    setVisible14(false)
                    setVisible15(true)
                elseif indexImg == 16 then
                    setVisible15(false)
                    setVisible16(true)
                elseif indexImg == 17 then
                    setVisible16(false)
                    setVisible17(true)
                elseif indexImg == 18 then
                    setVisible17(false)
                    setVisible18(true)
                elseif indexImg == 19 then
                    setVisible18(false)
                    setVisible19(true)
                elseif indexImg == 20 then
                    setVisible19(false)
                    setVisible20(true)
                elseif indexImg == 21 then
                    setVisible20(false)
                    setVisible21(true)
                elseif indexImg == 22 then
                    setVisible21(false)
                    setVisible22(true)
                elseif indexImg == 23 then
                    setVisible22(false)
                    setVisible23(true)
                elseif indexImg == 24 then
                    setVisible23(false)
                    setVisible24(true)
                elseif indexImg == 25 then
                    setVisible24(false)
                    setVisible25(true)
                elseif indexImg == 26 then
                    setVisible25(false)
                    setVisible26(true)
                elseif indexImg == 27 then
                    setVisible26(false)
                    setVisible27(true)
                elseif indexImg == 28 then
                    setVisible27(false)
                    setVisible28(true)
                elseif indexImg == 29 then
                    setVisible28(false)
                    setVisible29(true)
                end

                currentTime = 0
                loadingImg = false
            end

            if indexImg >= table.maxn(LOGO_FAILS) and _imageConnection then
                _imageConnection:Disconnect()
                _imageConnection = nil
            end
        end)

        --Swipe Effect
        local gradientDistance = 0
        local gradientSecondsPerCycle = 0.5
        local gradientSpeed = 1 / gradientSecondsPerCycle
        _swipeConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
            gradientDistance += deltaTime * gradientSpeed
            setTransparencyOffset(Vector2.new(-gradientDistance*1.75+1, 0))
            
            if gradientDistance >= 1.5 and _swipeConnection then
                _swipeConnection:Disconnect()
                _swipeConnection = nil
            end
        end)

        --Cleanup Connections
        return function()
            if _swipeConnection then
                _swipeConnection:Disconnect()
                _swipeConnection = nil
            end
            if _imageConnection then
                _imageConnection:Disconnect()
                _imageConnection = nil
            end
        end
    end, {})

    return e("Frame", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5,0.5),

        BackgroundTransparency = 1
    }, {
        UIAspectRatio = e("UIAspectRatioConstraint", {
            AspectRatio = 2,
        }),

        --[[
            I'm so sorry for what you have to look through,
            this component is just done for if you need to
            debug it. 😭🙏
        ]]--
        Image1 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[1],
            Visible = visible1,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image2 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[2],
            Visible = visible2,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image3 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[3],
            Visible = visible3,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image4 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[4],
            Visible = visible4,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image5 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[5],
            Visible = visible5,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image6 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[6],
            Visible = visible6,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image7 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[7],
            Visible = visible7,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image8 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[8],
            Visible = visible8,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image9 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[9],
            Visible = visible9,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image10 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[10],
            Visible = visible10,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image11 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[11],
            Visible = visible11,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image12 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[12],
            Visible = visible12,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image13 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[13],
            Visible = visible13,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image14 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[14],
            Visible = visible14,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image15 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[15],
            Visible = visible15,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image16 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[16],
            Visible = visible16,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image17 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[17],
            Visible = visible17,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image18 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[18],
            Visible = visible18,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image19 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[19],
            Visible = visible19,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image20 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[20],
            Visible = visible20,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image21 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[21],
            Visible = visible21,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image22 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[22],
            Visible = visible22,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image23 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[23],
            Visible = visible23,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image24 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[24],
            Visible = visible24,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image25 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[25],
            Visible = visible25,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image26 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[26],
            Visible = visible26,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image27 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[27],
            Visible = visible27,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image28 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[28],
            Visible = visible28,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
        Image29 = e("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5,0.5),

            Image = LOGO_FAILS[29],
            Visible = visible29,

            BackgroundTransparency = 1
        }, {
            TransparencyGradient = e("UIGradient", {
                Rotation = gradientRotation,
                Offset = transparencyOffset,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),
        }),
    })
end
