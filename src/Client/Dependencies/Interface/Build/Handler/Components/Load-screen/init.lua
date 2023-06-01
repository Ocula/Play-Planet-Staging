-- Build our Loading interface
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Primary dependencies
local Maid = require(Knit.Library.Maid)

local Load = {}
Load.__index = Load

-- UI dependencies
local Fusion = require(Knit.Library.Fusion)

-- | Ocula's UI Component Handler. Use :Get("path/to/instance/within/Components/Folder") to get the component for building.
local Handler = require(Knit.Modules.Interface.get)

-- Fusion primary dependencies
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed

-- Load Screen
local LoadScreen = Handler:Get("Load-screen/Screen")

function Load.ResolveUDimFromOffset(resolution, vector) -- For both Size and Position
	return Computed(function()
		local vec = vector:get()
		local res = resolution:get()

		local x, y = vec.X, vec.Y

		return UDim2.fromScale(x / res, y / res)
	end)
end

function Load.QuickResolveVector2ToResolution(res, vector)
	return Vector2.new(vector.X / res:get(), vector.Y / res:get())
end

function Load.new()
	local self = setmetatable({
		TextureAdd = 2,
		_maid = Maid.new(),
	}, Load)

	self.props = {
		LoadingBar = {},
		BackgroundTexture = {},

		Resolution = State(1024),
		Transparency = State(0),
		LoadingPercentage = State(0.1),

		-- Spring Data
		Springs = {
			SizePop = {
				Speed = 25,
				DampingRatio = 1,
			},

			Transparency = {
				Speed = 50,
				DampingRatio = 1,
			},

			Building = {
				Speed = 30,
				DampingRatio = 1,
			},

			Doors = {
				Speed = 30,
				DampingRatio = 0.5,
			},
		},

		-- Internal Data Below
		Logo = {
			Memory = {
				_size = Vector2.new(0.3, 0.3),
				_position = Vector2.new(0.5, 0.5),
			},
		},

		Doors = {
			Right = {},
			Left = {},
		},

		Building = {
			Memory = {
				_size = Vector2.new(771, 318),
				_position = Vector2.new(440.5, 770),
			},
		},
		Roof = {
			Rotation = State(0),

			Memory = {
				_size = Vector2.new(872, 451),
				_position = Vector2.new(441, 401),
				_rotation = 0,
			},
		},
		Silo = {
			Memory = {
				_size = Vector2.new(256, 872),
				_position = Vector2.new(876, 512),
			},
		},

		Grass = {
			Memory = {
				_size = Vector2.new(984, 119),
				_position = Vector2.new(512, 929.50),
			},
		},
	}

	-- Set states
	for index, property in pairs(self.props) do
		if property.Memory then -- Create our state values
			for valueName, newValue in pairs(property.Memory) do
				property[valueName] = State(newValue)
			end
		end
	end

	-- Prep BackgroundTexture
	self.props.BackgroundTexture.Transparency = Computed(function()
		local currentTransparency = self.props.Transparency:get()
		return 0.95 + currentTransparency
	end)

	self.props.BackgroundTexture.Position = State(UDim2.new(0, 0, 0, 0))

	-- Doors
	self.props.Doors.Right.Position = State(UDim2.new(0.5, 0, 0, 0))
	self.props.Doors.Left.Position = Computed(function() -- Whenever the Right door moves, the left will move with it.
		local rightDoorPosition = self.props.Doors.Right.Position:get().X.Scale
		local distanceFromHalf = rightDoorPosition - 0.5
		local leftPosition = 0.5 - distanceFromHalf

		return UDim2.new(leftPosition, 0, 0, 0)
	end)

	-- Loading Bar
	self.props.LoadingBar.ContainerSize = UDim2.new(1 + 256 / self.props.Resolution:get(), 0, 0.4, 0)
	self.props.LoadingBar.Position = UDim2.new(0.5 + (200 / self.props.Resolution:get()) / 2, 0, 1.4, 0)
	self.props.LoadingBar.Size = Computed(function()
		local loadingBar = self.props.LoadingPercentage:get()
		if loadingBar > 1 then
			loadingBar = 1
		end
		return UDim2.new(loadingBar, -10, 1, -10)
	end)

	-- Building
	self.props.Building.Size = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Building._size)
	self.props.Building.Position = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Building._position)
	self.props.Building.Rotation = Computed(function()
		local orig = self.props.Building.Memory._position
		local new = self.props.Building._position:get()

		local mag = (new - orig).Magnitude

		return mag * 0.1
	end)

	-- Roof
	self.props.Roof.Size = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Roof._size)
	self.props.Roof.Position = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Roof._position)
	self.props.Roof.Rotation = Computed(function()
		local orig = self.props.Roof.Memory._position
		local new = self.props.Roof._position:get()

		local mag = (new - orig).Magnitude

		return -(mag * 0.1)
	end)

	-- Silo
	self.props.Silo.Size = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Silo._size)
	self.props.Silo.Position = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Silo._position)

	-- Grass
	self.props.Grass.Size = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Grass._size)
	self.props.Grass.Position = Load.ResolveUDimFromOffset(self.props.Resolution, self.props.Grass._position)

	-- Logo
	self.props.Logo.Size = Computed(function()
		local buildingOrig = self.props.Building.Memory._position
		local newSize = self.props.Building._position:get()

		local mag = (newSize - buildingOrig).magnitude
		local magRes = (mag / self.props.Resolution:get()) * 0.8 -- Just a bit of throttling

		local logoOrig = self.props.Logo.Memory._size

		return UDim2.new(logoOrig.X + magRes, 0, logoOrig.Y + magRes, 0)
	end)

	self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
		local currentOverlayPosition = self.props.BackgroundTexture.Position:get()
		local currentSet = {
			X = currentOverlayPosition.X.Offset + self.TextureAdd,
			Y = currentOverlayPosition.Y.Offset + self.TextureAdd,
		}

		if currentSet.X >= (self.props.Resolution:get() / 2) then
			currentSet.X = 0
			currentSet.Y = 0
		end

		self.props.BackgroundTexture.Position:set(UDim2.new(0, currentSet.X, 0, currentSet.Y))
	end))

	self._object = LoadScreen(self.props)
	self._maid:GiveTask(self._object)

	return self
end

function Load:Hide()
	self:Shake(6)
	task.delay(0.005, function()
		self.props.Transparency:set(1)
	end)

	task.delay(3, function()
		self._maid:DoCleaning()
	end)
end

function Load:SetDoor(num) -- x: number
	self.props.Doors.Right.Position:set(UDim2.new(num, 0, 0, 0))
end

function Load:Shake(velocity)
	local randoms = {
		X = (math.random(-10, 10) * velocity),
		Y = (math.random(-30, -10) * velocity),
	}

	local origin = {
		Building = self.props.Building.Memory._position,
		Roof = self.props.Roof.Memory._position,
	} -- Vector2s that mark the origin.

	local newGoals = {
		Building = origin.Building + Vector2.new(randoms.X, randoms.Y),
		Roof = origin.Roof + Vector2.new(randoms.X, randoms.Y * 1.1),
	}

	self.props.Building._position:set(newGoals.Building)
	self.props.Roof._position:set(newGoals.Roof)

	task.delay(0.125, function()
		self.props.Building._position:set(origin.Building)
		self.props.Roof._position:set(origin.Roof)
	end)
end

function Load:SetLoadingPercentage(set)
	self.props.LoadingPercentage:set(set)
end

function Load:GetLoadingPercentage()
	return self.props.LoadingPercentage:get()
end

function Load:Destroy()
	self._maid:DoCleaning()
end

return Load
