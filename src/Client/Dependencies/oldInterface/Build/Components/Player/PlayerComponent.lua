local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)

local PlayerTheme = require(Knit.Modules.Interface.Build.Themes.PlayerTheme) -- Can flesh out theme in here. Good for editing Team Colors & Whatnot
local PlayerComponent = Roact.Component:extend("Player")

function PlayerComponent:init()
	-- SetState
	self:setState({
		playerImage = self.props.playerImage,
		score = self.props.score,
	})
end

function PlayerComponent:render()
	local score = self.state.score
	local playerImage = self.state.playerImage

	return Roact.createElement(PlayerTheme.Consumer, {
		render = function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.9, 0.9),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
			}, {
				padding = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.8),
				}, {
					score = Roact.createElement("Folder", {}, {
						bottom = Roact.createElement("TextLabel", {
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							RichText = true,
							Text = score,
							TextColor3 = Color3.fromRGB(255, 123, 0),
							TextScaled = true,
							TextSize = 40,
							TextWrapped = true,
							BackgroundColor3 = Color3.fromRGB(255, 160, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(0.75, 2, 0.5, 8),
							Size = UDim2.fromScale(0.5, 0.5),
							Visible = false,
							ZIndex = 5,
							AutoLocalize = false,
						}),

						middle = Roact.createElement("TextLabel", {
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							RichText = true,
							Text = score,
							TextColor3 = Color3.fromRGB(255, 160, 0),
							TextScaled = true,
							TextSize = 40,
							TextWrapped = true,
							BackgroundColor3 = Color3.new(255 / 255, 160 / 255, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(0.75, 1, 0.5, 5),
							Size = UDim2.fromScale(0.5, 0.5),
							Visible = false,
							ZIndex = 6,
							AutoLocalize = false,
						}),

						top = Roact.createElement("TextLabel", {
							FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json"),
							RichText = true,
							Text = score,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							TextSize = 40,
							TextWrapped = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							Position = UDim2.new(0.75, 2, 0.5, 6),
							Size = UDim2.fromScale(0.5, 0.5),
							Visible = false,
							ZIndex = 7,
							AutoLocalize = false,
						}),
					}),

					uICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),

					bottom1 = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 123, 0),
						Position = UDim2.new(0.5, 2, 0.5, 2),
						Size = UDim2.new(1, 8, 1, 8),
						ZIndex = 2,
					}, {
						uICorner1 = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
					}),

					middle1 = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 160, 0),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 8, 1, 8),
						ZIndex = 2,
					}, {
						uICorner2 = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
					}),

					top1 = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Position = UDim2.new(0.5, -1, 0.5, -1),
						Size = UDim2.new(1, 8, 1, 8),
					}, {
						uICorner3 = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
					}),

					image = Roact.createElement("ImageLabel", {
						Image = playerImage,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 3),
						Size = UDim2.new(1, 3, 1, 3),
						ZIndex = 4,
					}, {
						uICorner4 = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(1, 0),
						}),
					}),

					streak = Roact.createElement("ImageLabel", {
						Image = "rbxassetid://8597342215",
						ImageColor3 = Color3.fromRGB(238, 247, 237),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(27, 42, 53),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 40, 1, 40),
						Visible = false,
					}),
				}),
			})
		end,
	})
end

return PlayerComponent
