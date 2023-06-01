local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)
local Otter = require(Knit.Modules.Interface.Utility.Otter)
local InterfaceUtils = require(Knit.Modules.Interface.Utility.InterfaceUtils)

--
local Splash = Roact.Component:extend("Splash")

local utility = {
	motors = {}, -- external motor usage

	resolution = 1024, -- splash screen resolution

	guiPositionResolutions = {
		roof = { X = 441, Y = 401 },
		building = { X = 440.5, Y = 770 },
	},

	loopTable = {
		X = 0,
		Y = 0,

		Add = 1.25,
	},

	hidden = false,
}

function Splash:init()
	-- Listen Transparency
	self.listenTransparency, self.setTransparency = Roact.createBinding(0)

	utility.motors.transparency = Otter.createSingleMotor(0)

	utility.motors.transparency:onStep(function(value)
		self.setTransparency(value)
	end)

	-- Background Texture Loop
	self.ref = Roact.createRef()

	self.BackgroundTextureBind, self.SetBackgroundTexture = Roact.createBinding({
		X = 0,
		Y = 0,
	})

	RunService.RenderStepped:Connect(function(dt)
		utility.loopTable.X += utility.loopTable.Add
		utility.loopTable.Y += utility.loopTable.Add

		if utility.loopTable.X >= utility.resolution / 2 then
			utility.loopTable.X = 0
			utility.loopTable.Y = 0
		end

		self.SetBackgroundTexture(utility.loopTable)
	end)

	-- Loading Bar set
	self.LoadingBarBind, self.SetLoadingBind = Roact.createBinding(0.1)

	utility.SetLoadPercentage = function(set)
		if set > 1 then
			set = 1
		end
		self.SetLoadingBind(set)
	end

	-- Roof
	self.roofMotor = Otter.createGroupMotor({
		X = utility.guiPositionResolutions.roof.X / utility.resolution,
		Y = utility.guiPositionResolutions.roof.Y / utility.resolution,
	})

	self.roofBind, self.setRoofBind = Roact.createBinding({
		X = utility.guiPositionResolutions.roof.X / utility.resolution,
		Y = utility.guiPositionResolutions.roof.Y / utility.resolution,
	})

	self.roofMotor:onStep(function(value)
		self.setRoofBind(value)
	end)

	-- Building
	self.buildingMotor = Otter.createGroupMotor({
		X = utility.guiPositionResolutions.building.X / utility.resolution,
		Y = utility.guiPositionResolutions.building.Y / utility.resolution,
	})

	self.buildingBind, self.setbuildingBind = Roact.createBinding({
		-- Position
		X = utility.guiPositionResolutions.building.X / utility.resolution,
		Y = utility.guiPositionResolutions.building.Y / utility.resolution,
	})

	self.buildingMotor:onStep(function(value)
		self.setbuildingBind(value)
	end)

	-- Doors
	self.doorMotors = {
		Left = Otter.createSingleMotor(0.5),
		Right = Otter.createSingleMotor(0.5),
	}

	self.LeftDoorBind, self.setLeftDoorBind = Roact.createBinding(0.5) -- 0.35
	self.RightDoorBind, self.setRightDoorBind = Roact.createBinding(0.5) -- 0.65

	self.doorMotors.Left:onStep(function(value)
		self.setLeftDoorBind(value)
	end)

	self.doorMotors.Right:onStep(function(value)
		self.setRightDoorBind(value)
	end)

	-- Setup for alt functions
	utility.motors.doors = self.doorMotors
	utility.motors.building = self.buildingMotor
	utility.motors.roof = self.roofMotor
end

function Splash:hide()
	if utility.hidden then
		return
	end
	utility.hidden = true

	self:shake(3)

	utility.motors.transparency:setGoal(Otter.spring(1, {
		frequency = 5.5,
		dampingRatio = 1,
	}))

	task.wait(1)
end

function Splash:setDoorGoals(left, right, options)
	utility.motors.doors.Left:setGoal(Otter.spring(left, options))
	utility.motors.doors.Right:setGoal(Otter.spring(right, options))
end

function Splash:setLoadPercentage(perc)
	utility.SetLoadPercentage(perc)
end

function Splash:shake(vel, options)
	local randoms = {
		X = math.random(-10, 10) * vel,
		Y = math.random(-30, -10) * vel,
	}

	local goals = {
		building = {
			X = (utility.guiPositionResolutions.building.X + randoms.X) / utility.resolution,
			Y = (utility.guiPositionResolutions.building.Y + randoms.Y) / utility.resolution,
		},

		roof = {
			X = (utility.guiPositionResolutions.roof.X + randoms.X) / utility.resolution,
			Y = (utility.guiPositionResolutions.roof.Y + (randoms.Y * 1.1)) / utility.resolution,
		},
	}

	utility.motors.building:setGoal({
		X = Otter.spring(goals.building.X, {
			frequency = 1.5 * vel,
			dampingRatio = 0.5,
		}),
		Y = Otter.spring(goals.building.Y, {
			frequency = 1.5 * vel,
			dampingRatio = 0.5,
		}),
	})

	utility.motors.roof:setGoal({
		X = Otter.spring(goals.roof.X, {
			frequency = 1.5 * vel,
			dampingRatio = 0.5,
		}),
		Y = Otter.spring(goals.roof.Y, {
			frequency = 1.5 * vel,
			dampingRatio = 0.5,
		}),
	})

	task.delay(0.125, function()
		utility.motors.roof:setGoal({
			X = Otter.spring(utility.guiPositionResolutions.roof.X / utility.resolution, {
				frequency = 3 * vel,
				dampingRatio = 0.2,
			}),
			Y = Otter.spring(utility.guiPositionResolutions.roof.Y / utility.resolution, {
				frequency = 3 * vel,
				dampingRatio = 0.2,
			}),
		})

		utility.motors.building:setGoal({
			X = Otter.spring(utility.guiPositionResolutions.building.X / utility.resolution, {
				frequency = 3 * vel,
				dampingRatio = 0.4,
			}),
			Y = Otter.spring(utility.guiPositionResolutions.building.Y / utility.resolution, {
				frequency = 3 * vel,
				dampingRatio = 0.4,
			}),
		})
	end)
end

function Splash:render()
	return Roact.createElement("ScreenGui", {
		[Roact.Ref] = self.ref,
		IgnoreGuiInset = true,
	}, {
		Splash = Roact.createElement(InterfaceUtils.getFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = self.listenTransparency,
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, {
			UIGradient = InterfaceUtils.getGradient({
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0.270588, 0.788235, 0.992156)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0.615686, 1)),
				}),
			}),

			LoadingMap = Roact.createElement(InterfaceUtils.getFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				AnchorPoint = Vector2.new(0, 0),
			}, {

				Logo = Roact.createElement(InterfaceUtils.getFrame, {
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					Size = self.buildingBind:map(function(value)
						local orig = Vector2.new(
							utility.guiPositionResolutions.building.X,
							utility.guiPositionResolutions.building.Y
						)
						local new = Vector2.new(value.X * utility.resolution, value.Y * utility.resolution)
						local mag = (new - orig).Magnitude / utility.resolution

						return UDim2.new(0.3 + mag, 0, 0.3 + mag, 0)
					end),
					--UDim2.new(0.3, 0, 0.3, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = self.buildingBind:map(function(value)
						return UDim2.new(
							0.5 + (value.X - (utility.guiPositionResolutions.building.X / utility.resolution)) * 0.1,
							0,
							0.35 + (value.Y - (utility.guiPositionResolutions.building.Y / utility.resolution)) * 0.3,
							0
						)
					end),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					--ImageTransparency = self.listenTransparency,
				}, {

					Building = Roact.createElement(InterfaceUtils.getImageLabel, {
						Image = InterfaceUtils.getImageId("Building"),
						Size = UDim2.new(771 / utility.resolution, 0, 318 / utility.resolution, 0),
						Position = self.buildingBind:map(function(value)
							return UDim2.new(value.X, 0, value.Y, 0)
						end),
						Rotation = self.buildingBind:map(function(value)
							-- alter relative to distance from origin
							local orig = Vector2.new(
								utility.guiPositionResolutions.building.X,
								utility.guiPositionResolutions.building.Y
							)
							local new = Vector2.new(value.X * utility.resolution, value.Y * utility.resolution)
							local mag = (new - orig).Magnitude
							return mag * 0.125 --* math.random(-1, 1)
						end),
						-- UDim2.new(440.5 / utility.resolution, 0, 770 / utility.resolution, 0),
						ZIndex = 2,
						ImageTransparency = self.listenTransparency,
					}, {
						Doors = Roact.createElement(InterfaceUtils.getFrame, {
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 3,
						}, {
							RightDoor = Roact.createElement(InterfaceUtils.getImageLabel, {
								Image = InterfaceUtils.getImageId("RightDoor"),
								Size = UDim2.new(188 / 771, 0, 318 / 318, 0),
								AnchorPoint = Vector2.new(0, 0),
								BackgroundTransparency = 1,
								Position = self.RightDoorBind:map(function(value)
									return UDim2.new(value, 0, 0, 0)
								end),
								--	UDim2.new(self.RightDoorBind.X, 0, self.RightDoorBind:getValue().Y, 0),
								-- [CLOSED]: X - 0.5
								-- [OPEN]: X - 0.625
								ZIndex = 4,
								ImageTransparency = self.listenTransparency,
							}),

							LeftDoor = Roact.createElement(InterfaceUtils.getImageLabel, {
								Image = InterfaceUtils.getImageId("LeftDoor"),
								BackgroundTransparency = 1,
								Size = UDim2.new(188 / 771, 0, 318 / 318, 0),
								AnchorPoint = Vector2.new(1, 0),
								Position = self.LeftDoorBind:map(function(value)
									return UDim2.new(value, 0, 0, 0)
								end),
								-- UDim2.new(self.LeftDoorBind.X, 0, self.RightDoorBind:getValue().Y, 0),
								-- [CLOSED]: X - 0.5
								-- [OPEN]: X - 0.375
								ZIndex = 4,
								ImageTransparency = self.listenTransparency,
							}),
						}),

						LoadingBar = Roact.createElement("Frame", {
							Size = UDim2.new(1 + (256 / utility.resolution), 0, 0.4, 0),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5 + (200 / utility.resolution) / 2, 0, 1.4, 0),
							BackgroundColor3 = Color3.new(1, 1, 1),
							ZIndex = 1,
							BackgroundTransparency = self.listenTransparency,
						}, {
							UICorner = Roact.createElement("UICorner", {
								CornerRadius = UDim.new(1, 0),
							}),
							LoadPercentage = Roact.createElement("Frame", {
								Size = self.LoadingBarBind:map(function(value)
									return UDim2.new(value, -10, 1, -10)
								end), --UDim2.new(0.1, -10, 1, -10),
								Position = UDim2.new(0, 5, 0, 5),
								AnchorPoint = Vector2.new(0, 0),
								BackgroundColor3 = Color3.new(0.407843, 0.886274, 0.423529),
								ClipsDescendants = true,
								BackgroundTransparency = self.listenTransparency,
								ZIndex = 3,
							}, {
								--[[StripeTexture = Roact.createElement("ImageLabel", {
									ZIndex = 4,
									BackgroundTransparency = 1,
									Size = UDim2.new(0, utility.resolution, 0, utility.resolution),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = self.BackgroundTextureBind:map(function(value)
										return UDim2.new(0, value.X / 2, 0, value.Y / 2)
									end),
									ScaleType = "Tile",
									TileSize = UDim2.new(0, utility.resolution / 2, 0, utility.resolution / 2),
									Rotation = self.buildingBind:map(function(value)
										-- alter relative to distance from origin
										local orig = Vector2.new(
											utility.guiPositionResolutions.building.X,
											utility.guiPositionResolutions.building.Y
										)
										local new =
											Vector2.new(value.X * utility.resolution, value.Y * utility.resolution)
										local mag = (new - orig).Magnitude
										return - (mag * 0.125) --* math.random(-1, 1)
									end),
									ImageTransparency = 0.95,
									Image = InterfaceUtils.getImageId("StripeTexture"),
									ImageColor3 = Color3.new(1, 1, 1),
								}), --]]
								UICorner_2 = Roact.createElement("UICorner", {
									CornerRadius = UDim.new(1, 0),
								}),
							}),
						}),
					}),

					Roof = Roact.createElement(InterfaceUtils.getImageLabel, {
						Image = InterfaceUtils.getImageId("Roof"),
						Size = UDim2.new(872 / utility.resolution, 0, 451 / utility.resolution, 0),
						Position = self.roofBind:map(function(value)
							return UDim2.new(value.X, 0, value.Y, 0)
						end),
						Rotation = self.roofBind:map(function(value)
							-- alter relative to distance from origin
							local orig = Vector2.new(
								utility.guiPositionResolutions.roof.X,
								utility.guiPositionResolutions.roof.Y
							)
							local new = Vector2.new(value.X * utility.resolution, value.Y * utility.resolution)
							local mag = (new - orig).Magnitude
							return (mag * 0.1)
						end),
						-- UDim2.new(441.00 / utility.resolution, 0, 401.00 / utility.resolution, 0),
						ZIndex = 4,
						ImageTransparency = self.listenTransparency,
					}),

					Silo = Roact.createElement(InterfaceUtils.getImageLabel, {
						Image = InterfaceUtils.getImageId("Silo"),
						Size = UDim2.new(256 / utility.resolution, 0, 872 / utility.resolution, 0),
						Position = UDim2.new(876 / utility.resolution, 0, 512 / utility.resolution, 0),
						ZIndex = 1,
						ImageTransparency = self.listenTransparency,
					}),

					Grass = Roact.createElement(InterfaceUtils.getImageLabel, {
						Image = InterfaceUtils.getImageId("Grass"),
						Size = UDim2.new(984 / utility.resolution, 0, 119 / utility.resolution, 0),
						Position = UDim2.new(512 / utility.resolution, 0, 929.50 / utility.resolution, 0),
						ZIndex = 5,
						ImageTransparency = self.listenTransparency,
					}),
				}),

				BackgroundTexture = Roact.createElement(InterfaceUtils.getImageLabel, {
					BackgroundTransparency = 1,
					Size = UDim2.new(4, 0, 4, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = self.BackgroundTextureBind:map(function(value)
						return UDim2.new(0, value.X, 0, value.Y)
					end),
					ScaleType = "Tile",
					TileSize = UDim2.new(0, utility.resolution / 2, 0, utility.resolution / 2),
					Rotation = 0,
					ImageTransparency = self.listenTransparency:map(function(value)
						return 0.95 + value
					end),
					Image = InterfaceUtils.getImageId("BackgroundTexture"),
					ImageColor3 = Color3.new(1, 1, 1), --a
				}),
			}),
		}),
	})
end

return Splash
