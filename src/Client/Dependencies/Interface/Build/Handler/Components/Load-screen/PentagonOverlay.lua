local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local InterfaceUtils = require(Knit.Library.InterfaceUtils)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

return function(props)
	return New("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = InterfaceUtils.getImageId("BackgroundTexture"),
		ScaleType = "Tile",
		TileSize = UDim2.new(0, props.Resolution:get() / 2, 0, props.Resolution:get() / 2),
		Size = UDim2.new(4, 0, 4, 0),

		Position = props.BackgroundTexture.Position,
		ImageTransparency = props.BackgroundTexture.Transparency,
		Rotation = 0,
	})
end
