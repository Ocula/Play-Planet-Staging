local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)

-- Fusion primary dependencies
local New = Fusion.New
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring

return function(props)
	return New("Frame")({
		Name = "SplatterContainer",
		BackgroundTransparency = 1,
		Size = Spring(props.Size, 30, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Position = Spring(props.Position, 30, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		[Children] = {
			SplatterImage = New("ImageLabel")({
				Image = props.ImageId,
				Size = Spring(props.ImageSize, 0.5, 1),
				Position = Spring(props.ImagePosition, 0.5, 1), --UDim2.new(0.5, 0, 0.5, 0),
				ImageTransparency = Spring(props.Transparency, 30, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
		},
	})
end
