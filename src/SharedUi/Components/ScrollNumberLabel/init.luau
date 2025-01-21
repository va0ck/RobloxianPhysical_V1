--!strict
--[[
    Ported over version of Elttob Fusion obby number scroll.
]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local DigitMover = require(script.DigitMover)

type numberScrollProps = {
    NumDigits: number,
    Value: number,

    Position: UDim2,
    AnchorPoint: Vector2,
    Size: UDim2,

    Font: Font,
    TextColor3: Color3,
}

return function(props: numberScrollProps)
    local digitsTable = {}

    for i = 1, props.NumDigits do
        table.insert(digitsTable, e(DigitMover,{
            tableIndex = i,
            Value = props.Value,

            Font = props.Font,
            TextColor3 = props.TextColor3,
        }, {}))
    end

    return e("Frame", {        
        Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,

        BackgroundTransparency = 1,
		ClipsDescendants = true,
    }, {
        UIListLayout = e("UIListLayout", {
            SortOrder = "LayoutOrder",
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center"
        }),
        table.unpack(digitsTable)
    })
end
