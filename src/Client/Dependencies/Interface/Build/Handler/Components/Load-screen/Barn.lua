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

local function Barn(props)
	warn("Barn Props:", props)
	return New("Frame")({
		Name = "Logo",
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = Spring(props.Logo.Size, props.Springs.SizePop.Speed, props.Springs.SizePop.DampingRatio),
		Position = UDim2.new(0.5, 0, 0.35, 0), -- TODO: Change
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,

		[Children] = {
			Building = New("ImageLabel")({
				Name = "Building",
				Image = InterfaceUtils.getImageId("Building"),
				Size = props.Building.Size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = Spring(
					props.Building.Position,
					props.Springs.Building.Speed,
					props.Springs.Building.DampingRatio
				), --TODO: Finetune Spring
				Rotation = Spring(props.Building.Rotation, 25, 0.7), -- TODO: Finetune Spring
				ZIndex = 2,
				BackgroundTransparency = 1,
				ImageTransparency = Spring(
					props.Transparency,
					props.Springs.Transparency.Speed,
					props.Springs.Transparency.DampingRatio
				),

				[Children] = {
					Doors = New("Frame")({
						Name = "Doors",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,

						[Children] = {
							RightDoor = New("ImageLabel")({
								Name = "RightDoor",
								Image = InterfaceUtils.getImageId("RightDoor"),
								Size = UDim2.new(188 / 771, 0, 318 / 318, 0),
								AnchorPoint = Vector2.new(0, 0),
								BackgroundTransparency = 1,
								Position = Spring(
									props.Doors.Right.Position,
									props.Springs.Doors.Speed,
									props.Springs.Doors.DampingRatio
								),
								--	UDim2.new(self.RightDoorBind.X, 0, self.RightDoorBind:getValue().Y, 0),
								-- [CLOSED]: X - 0.5
								-- [OPEN]: X - 0.625
								ZIndex = 4,
								ImageTransparency = Spring(
									props.Transparency,
									props.Springs.Transparency.Speed,
									props.Springs.Transparency.DampingRatio
								),
							}),
							LeftDoor = New("ImageLabel")({
								Name = "LeftDoor",
								Image = InterfaceUtils.getImageId("LeftDoor"),
								Size = UDim2.new(188 / 771, 0, 318 / 318, 0),
								AnchorPoint = Vector2.new(1, 0),
								BackgroundTransparency = 1,
								Position = Spring(
									props.Doors.Left.Position,
									props.Springs.Doors.Speed,
									props.Springs.Doors.DampingRatio
								),
								-- UDim2.new(self.LeftDoorBind.X, 0, self.RightDoorBind:getValue().Y, 0),
								-- [CLOSED]: X - 0.5
								-- [OPEN]: X - 0.375
								ZIndex = 4,
								ImageTransparency = Spring(
									props.Transparency,
									props.Springs.Transparency.Speed,
									props.Springs.Transparency.DampingRatio
								),
							}),
						},
					}),

					LoadingBar = New("Frame")({
						Name = "LoadingBar",
						Size = props.LoadingBar.ContainerSize,
						Position = props.LoadingBar.Position,
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
						ZIndex = 1,
						BackgroundTransparency = Spring(
							props.Transparency,
							props.Springs.Transparency.Speed,
							props.Springs.Transparency.DampingRatio
						),

						[Children] = {

							UICorner = New("UICorner")({
								CornerRadius = UDim.new(1, 0),
							}),

							LoadPercentage = New("Frame")({
								Name = "LoadPercentage",
								Size = Spring(props.LoadingBar.Size, 20, 0.8), --TODO: FINETUNE SPRING. UDim2.new(0.1, -10, 1, -10),
								Position = UDim2.new(0, 5, 0, 5),
								AnchorPoint = Vector2.new(0, 0),
								BackgroundColor3 = Color3.new(0.407843, 0.886274, 0.423529),
								ClipsDescendants = true,
								BackgroundTransparency = Spring(
									props.Transparency,
									props.Springs.Transparency.Speed,
									props.Springs.Transparency.DampingRatio
								),
								ZIndex = 3,

								[Children] = {
									UICorner_2 = New("UICorner")({
										CornerRadius = UDim.new(1, 0),
									}),
								},
							}),
						},
					}),
				},
			}),

			Roof = New("ImageLabel")({
				Name = "Roof",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = InterfaceUtils.getImageId("Roof"),
				Size = props.Roof.Size,
				Position = Spring(props.Roof.Position, 20, 0.5), -- TODO: FINETUNE SPRING.
				Rotation = Spring(props.Roof.Rotation, 10, 0.5), -- TODO: FINETUNE SPRING
				--[=[
                    Position = self.roofBind:map(function(value)
                        return UDim2.new(value.X, 0, value.Y, 0)
                    end),
                    Rotation = self.roofBind:map(function(value)
                        -- alter relative to distance from origin
                        local orig = Vector2.new(
                            utility.guiPositionResolutions.roof.X,
                            utility.guiPositionResolutions.roof.Y
                        )
                        local new = Vector2.new(value.X * props.Resolution, value.Y * props.Resolution)
                        local mag = (new - orig).Magnitude
                        return (mag * 0.1)
                    end),
                --]=]
				-- UDim2.new(441.00 / props.Resolution, 0, 401.00 / props.Resolution, 0),
				ImageTransparency = Spring(
					props.Transparency,
					props.Springs.Transparency.Speed,
					props.Springs.Transparency.DampingRatio
				),
				ZIndex = 4,
			}),

			Silo = New("ImageLabel")({
				Name = "Silo",
				Image = InterfaceUtils.getImageId("Silo"),
				Size = props.Silo.Size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = props.Silo.Position,
				ZIndex = 1,
				ImageTransparency = Spring(
					props.Transparency,
					props.Springs.Transparency.Speed,
					props.Springs.Transparency.DampingRatio
				),
			}),

			Grass = New("ImageLabel")({
				Name = "Grass",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = InterfaceUtils.getImageId("Grass"),
				Size = props.Grass.Size,
				BackgroundTransparency = 1,
				Position = props.Grass.Position,
				ZIndex = 5,
				ImageTransparency = Spring(
					props.Transparency,
					props.Springs.Transparency.Speed,
					props.Springs.Transparency.DampingRatio
				),
			}),
		},
	})
end

return Barn
