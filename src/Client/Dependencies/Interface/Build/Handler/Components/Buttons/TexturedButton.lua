local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Handler = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local AssetLibrary = require(Knit.Library.AssetLibrary)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

local OnEvent = Fusion.OnEvent

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

local TilePattern = Handler:Get("Patterns/TilePattern")

--[[

Properties (organized by priority):
    Parent,
    ButtonColor,
    ImageRectOffset, -- For animating button textures
    
    CornerClip,
    TextureTransparency,
    Transparency, -- Entire button transparency.
]]

return function(props)
	if not props.ImageRectOffset then
		props.ImageRectOffset = State(Vector2.new(0, 0))
	end

	--props.CircleButtonRender = State(Vector2.new(0, 0))

	return New("TextButton")({
		Parent = props.Parent,
		Name = "Button",
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		Text = "",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.ButtonColor, --Color3.fromRGB(246, 175, 236), -- TODO: Change
		Position = props.Position, --UDim2.fromScale(0.5, 0.5),
		Size = props.Size,
		ZIndex = 2,

		[OnEvent("Activated")] = function()
			props.Signal:Fire()
		end,

		[Children] = {
			TilePattern(props),

			New("UICorner")({
				Name = "UICorner",
				CornerRadius = props.CornerClip or UDim.new(0.5, 0),
			}),

			New("ImageLabel")({
				Name = "BottomPaintDrip",
				Image = "rbxassetid://12181515975",
				ImageColor3 = props.ButtonColor,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(0.8, 0.5),
			}),

			New("ImageLabel")({
				Name = "BubbleFade",
				Image = "rbxassetid://12180711062",
				ImageColor3 = props.ButtonColor,
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

			New("TextLabel")({
				Name = "Text",
				FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
				Text = props.Text,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 32,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 3,
			}),

			New("TextLabel")({
				Name = "TextShadow",
				FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
				Text = props.Text,
				TextColor3 = Color3.fromRGB(111, 111, 111),
				TextSize = 32,
				TextTransparency = 0.5,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
			}),
		},
	})
end
