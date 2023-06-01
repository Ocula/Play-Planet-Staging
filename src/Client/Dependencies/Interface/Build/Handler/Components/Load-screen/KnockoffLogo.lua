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

return New("Frame")({
	Name = "KnockoffLogo",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(38, 200, 73),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	ZIndex = 3,

	[Children] = {
		New("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0.5, 0),
		}),

		New("TextLabel")({
			Name = "TextShadow",
			FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
			Text = "Knockoff",
			TextColor3 = Color3.fromRGB(111, 111, 111),
			TextScaled = true,
			TextSize = 32,
			TextTransparency = 0.5,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		}),

		New("TextLabel")({
			Name = "Text",
			FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
			Text = "Knockoff",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 32,
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,
		}),

		New("ImageLabel")({
			Name = "PaintDrip3",
			Image = "rbxassetid://12156989632",
			ImageColor3 = Color3.fromRGB(38, 200, 73),
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.78, 0.925),
			Size = UDim2.fromScale(1, 0.5),
		}),

		New("ImageLabel")({
			Name = "PaintDrip2",
			Image = "rbxassetid://12156990479",
			ImageColor3 = Color3.fromRGB(38, 200, 73),
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.525, 0.95),
			Size = UDim2.fromScale(1, 0.5),
		}),

		New("ImageLabel")({
			Name = "PaintDrip1",
			Image = "rbxassetid://12156990479",
			ImageColor3 = Color3.fromRGB(38, 200, 73),
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.25, 0.95),
			Size = UDim2.fromScale(0.5, 0.5),
		}),

		New("ImageLabel")({
			Name = "Bubbles",
			Image = "rbxassetid://12179976153",
			ImageColor3 = Color3.fromRGB(86, 176, 93),
			ImageRectOffset = Vector2.new(0, 512),
			ImageRectSize = Vector2.new(1.02e+03, 1.02e+03),
			ImageTransparency = 0.5,
			ScaleType = Enum.ScaleType.Crop,
			TileSize = UDim2.fromOffset(512, 512),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,

			[Children] = {
				New("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0.5, 0),
				}),
			},
		}),

		New("ImageLabel")({
			Name = "BubbleFade",
			Image = "rbxassetid://12180711062",
			ImageColor3 = Color3.fromRGB(38, 200, 73),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,

			[Children] = {
				New("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0.5, 0),
				}),
			},
		}),

		New("UIAspectRatioConstraint")({
			Name = "UIAspectRatioConstraint",
			AspectRatio = 4,
		}),
	},
})
