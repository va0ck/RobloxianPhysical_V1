--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

type digitalMoverProps = {
    tableIndex: number,

    Value: number,

    Font: Font,
    TextColor3: Color3,
}

return function(props: digitalMoverProps)
    local fauxRotationStyles, fauxRotationApi = ReactSpring.useSpring(function()
        --Position same as like math.
        return { 
            from = {rotationPos = UDim2.fromScale(0, -(math.floor(props.Value / 10^(props.tableIndex - 1) % 10))) },
            config = { mass = 0.5, tension = 500 + (props.tableIndex * 50) }
        }
    end)

    React.useEffect(function()
        fauxRotationApi.start({
            rotationPos = UDim2.fromScale(0, -(math.floor(props.Value / 10^(props.tableIndex - 1) % 10)))
        })
    end, {props.Value})

    return e("Frame", {
        Name = "Digit" .. props.tableIndex,

        LayoutOrder = -props.tableIndex,
        Size = UDim2.fromScale(0.2, 1),
        SizeConstraint = "RelativeYY",

        BackgroundTransparency = 1,
    }, {
        DigitMover = e("Frame", {

            Position = fauxRotationStyles.rotationPos,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            
        }, {
            React.Children.map({0,1,2,3,4,5,6,7,8,9,0}, function(digit, index)
                return e("TextLabel", {
                    Name = "Label" .. index,
                    
                    Position = UDim2.fromScale(0, index - 1),
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    
                    FontFace = props.Font,
                    Text = digit,
                    TextScaled = true,
                    TextColor3 = props.TextColor3,
                })
            end)
        })
    })
end
