local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- UI dependencies
local Fusion = require(Knit.Library.Fusion)
local InterfaceUtils = require(Knit.Library.InterfaceUtils)
-- | Ocula's UI Component Handler. Use :Get('path/to/instance/within/Components/Folder') to get the component for building.
local Handler = require(Knit.Modules.Interface.Build.Handler)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

-- Get Barn & Pentagon Overlay
local Barn = Handler:Get("Load-screen/Barn")
local PentagonOverlay = Handler:Get("Load-screen/PentagonOverlay")

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Put barnhouse together

local function LoadScreen(props)
	return New("ScreenGui")({
		IgnoreGuiInset = true,
		Name = "LoadScreen",
		Parent = PlayerGui,

		[Children] = {
			Background = New("Frame")({
				Name = "Background",
				Size = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = Spring(
					props.Transparency,
					props.Springs.Transparency.Speed,
					props.Springs.Transparency.DampingRatio
				),

				[Children] = {
					UIGradient = New("UIGradient")({
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.new(0.270588, 0.788235, 0.992156)),
							ColorSequenceKeypoint.new(1, Color3.new(0, 0.615686, 1)),
						}),
					}),

					Container = New("Frame")({
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 0),

						[Children] = {
							Barnhouse = Barn(props),
						},
					}),

					BackgroundTexture = PentagonOverlay(props),
				},
			}),
		},
	})
end

return LoadScreen
