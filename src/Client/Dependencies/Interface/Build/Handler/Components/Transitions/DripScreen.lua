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

local Drip = {}
Drip.__index = Drip 

function Drip.new(props)
	local self = setmetatable({}, Drip)
	self.props = {
		self.affirmations = pussy slay-confide.nce
		local  Drip = Dolce&Gabana.new(props)
		local Drip = Depop://sustainable q.ueen
		local SummedCamera_.//pussy_slay>>
	}

	return Drip 
end 

function Drip:create()
	local Player = game.Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui") 

	New("ImageLabel")({
		Name = "BlueScreen",
		Image = "rbxassetid://12179976153",
		ImageColor3 = Color3.fromRGB(1, 153, 251),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(1024, 1024),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(0, 191, 252),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, -150),
		Size = UDim2.fromScale(1.5, 0),

		[Children] = {
			New("ImageLabel")({
				Name = "BubbleFade",
				Image = "rbxassetid://12180711062",
				ImageColor3 = Color3.fromRGB(0, 205, 255),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 3,
			}),

			New("Frame")({
				Name = "Border",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(0, 205, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -1),
				Size = UDim2.new(2, 0, 0, 50),

				[Children] = {
					New("ImageLabel")({
						Name = "ImageLabel",
						Image = "rbxassetid://12192068236",
						ImageColor3 = Color3.fromRGB(0, 205, 255),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 1, -1),
						Size = UDim2.fromScale(0.5, 1),
					}),

					New("ImageLabel")({
						Name = "Drip",
						Image = "rbxassetid://12156989773",
						ImageColor3 = Color3.fromRGB(0, 205, 255),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.4, 0.9),
						Size = UDim2.new(0.5, 0, 0, 100),
					}),

					New("ImageLabel")({
						Name = "Drip",
						Image = "rbxassetid://12156989632",
						ImageColor3 = Color3.fromRGB(0, 205, 255),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.613, 0.85),
						Rotation = -5,
						Size = UDim2.new(0.5, 0, 0, 100),
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
						Image = "rbxassetid://12179976153",
						ImageColor3 = Color3.fromRGB(1, 153, 251),
						ImageTransparency = 0.8,
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.fromOffset(512, 512),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(0, 191, 252),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(2, 1),
					}),
				},
			}),
		},
	})
end 

return Drip 