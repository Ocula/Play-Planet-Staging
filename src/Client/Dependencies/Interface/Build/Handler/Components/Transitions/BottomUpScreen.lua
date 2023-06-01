local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

return New("ImageLabel")({
	Name = "OrangeScreen",
	Image = "rbxassetid://12181829304",
	ImageColor3 = Color3.fromRGB(247, 174, 0),
	ImageTransparency = 1,
	ScaleType = Enum.ScaleType.Tile,
	TileSize = UDim2.fromOffset(512, 512),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = Color3.fromRGB(255, 191, 0),
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 1),
	Size = UDim2.fromScale(1.5, 0),

	[Children] = {
		New("ImageLabel")({
			Name = "BubbleFade",
			Image = "rbxassetid://12180711062",
			ImageColor3 = Color3.fromRGB(255, 191, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Rotation = -180,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4,
		}),

		New("Frame")({
			Name = "Border",
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 191, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(2, 0.2),
			ZIndex = 3,

			[Children] = {
				New("ImageLabel")({
					Name = "ImageLabel",
					Image = "rbxassetid://12192068236",
					ImageColor3 = Color3.fromRGB(255, 191, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, -1, 1),
					Rotation = 180,
					Size = UDim2.fromScale(0.5, 1),
				}),
			},
		}),

		New("Frame")({
			Name = "Texture",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1),

			[Children] = {
				New("ImageLabel")({
					Name = "ImageLabel",
					Image = "rbxassetid://12198185194",
					ImageColor3 = Color3.fromRGB(245, 184, 0),
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.fromOffset(512, 512),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(0, 191, 252),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(10, 10),
				}),
			},
		}),
	},
})
