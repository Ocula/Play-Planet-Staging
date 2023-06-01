-- Used to fill an entire UI instance with a tile pattern.
-- Can feed it a CornerSize property to clip it to any UICorner object.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local Fusion = require(Knit.Library.Fusion)

-- Fusion primary dependencies
local New = Fusion.New
local Children = Fusion.Children

local Computed = Fusion.Computed

local Spring = Fusion.Spring
local Tween = Fusion.Tween

return function(props)
	local patternId = props.PatternID -- Choose a random PatternID if we aren't provided one.
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

	if not patternId then
		patternId = AssetLibrary.getRandom(AssetLibrary.Assets.Interface.Textures)
	end

	return New("ImageLabel")({
		Name = "Tile",
		BackgroundTransparency = 1,
		Image = patternId.ID,
		Size = UDim2.new(1, 0, 1, 0), -- All textures will resize to the parent object they are in.
		ImageTransparency = props.Transparency or 0.8,
		ImageColor3 = props.TextureColor or Color3.new(1, 1, 1),
		ImageRectSize = patternId.Size / 2,
		ImageRectOffset = props.ImageRectOffset, --, 20, 1), --Vector2.new(0, 0),
		ScaleType = Enum.ScaleType.Crop,

		[Children] = {
			UICorner = New("UICorner")({
				CornerRadius = props.CornerClip or UDim.new(0.5, 0),
			}),
		},
	})
end
