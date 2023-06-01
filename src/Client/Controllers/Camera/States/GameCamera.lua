--[[
    GameCamera by @ocula

    For platformer side-scroll Camera style. 
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Camera Dependencies
local CameraUtils = require(Knit.Modules.CameraUtils)
local CameraState = require(Knit.Modules.CameraState)

-- Object Dependencies
local BaseObject = require(Knit.Library.BaseObject)

local GameCamera = {
	Objects = {},
	Origin = CFrame.new(),

	cameraMaxDistance = 200, -- Realistically at this distance you can't see anything.

	screenBounds = {
		Y = { Min = -50, Max = 50 },
		X = { Min = -60, Max = 60 },
		Z = { Min = -20, Max = 20 },
	}, -- Where players will no longer be registered in camera. Relative stud-spacing to GameCamera.Origin.

	deltaTime = os.time(),

	FavorPlayer = true,
}

GameCamera.__index = GameCamera

-- Create a new GameCamera object.
-- Parameters: A table of objects, and an origin for the CameraBase (CFrame).
-- No objects or Origin is necessary, but ideally you will need to provide these for proper gameplay.
function GameCamera.new(objects, relativeOrigin, relativeMapSize)
	-- Camera Setup
	local self = setmetatable({}, GameCamera)
	local CameraController = Knit.GetController("Camera")

	self.Origin = relativeOrigin
	self.MapSize = relativeMapSize

	-- Testing
	-- self.addObject(workspace.Objects:GetChildren())

	for i, v in pairs(objects) do
		self:addObject(v) -- Players, Models, and BaseParts
	end

	self._camera = BaseObject.new()

	self._cameraState = CameraState.new()
	self._cameraState.CFrame = self.Origin
	self._cameraState.FieldOfView = 70

	--	self._camera.CameraState = self._cameraState [This could need troubleshooting in the future]
	self._cameraState.Render = function()
		self:Render()
	end

	CameraController.ListenToGameCamera:Fire(self)

	return self._cameraState
end

-- Render method.
-- A new method to CameraStackService added by @ocula to compile rendering functions into the StackService itself.
function GameCamera:Render()
	local lookat, magnitude = self:getLookAtAverage()
	local focus = lookat

	-- Fix lookat
	local yChange = (lookat.Y - self.Origin.Y) * 0.5 -- Gives the effect that we're following the player's Y position but we're staying closer to our Origin Y
	lookat = Vector3.new(lookat.X, self.Origin.Y + yChange, lookat.Z)

	if self.FavorPlayer then
		focus = self:getLooseFocus(lookat)
	end

	if magnitude < 20 then
		magnitude = 20
	end

	if lookat and magnitude and magnitude < math.huge then
		local target = (lookat + Vector3.new(0, 0, magnitude))
		local cf = CFrame.new(target, focus)

		self._cameraState.CFrame = self._cameraState.CFrame:Lerp(cf, 0.2) --Spring._target = target
		self._cameraState.FieldOfView = 70 --+ magnitude

		-- Debugging
		if os.time() - self.deltaTime > 0.1 then
			self.deltaTime = os.time()
		end
	end
end

-- Utility Functions

-- Adds an object to the GameCamera rendering table.
-- This object can also be a table of objects.
-- Objects that can be added to the render list are: Players, Models, BaseParts
function GameCamera:addObject(obj)
	if type(obj) == "userdata" then
		self.Objects[obj] = obj
		--warn("Adding object [:addobj]", obj)
	elseif type(obj) == "table" then
		if #obj == 0 then
			return
		end

		for i, v in pairs(obj) do
			if type(v) == "userdata" then
				self.Objects[v] = v
				--warn("Adding object [:addobj]", obj)
			end
		end
	end
end

-- Removes an object from the rendering table.
function GameCamera:removeObject(obj)
	GameCamera.Objects[obj] = nil
end

-- Get the Position and CFrame of an Object.
-- Can be either a Player object, a Model, or a BasePart.
function GameCamera.getPositionAndCFrame(obj)
	if obj:IsA("Player") then
		local character = obj.Character

		if character then
			local humRoot = character:FindFirstChild("HumanoidRootPart")

			if humRoot then
				return humRoot.Position, humRoot.CFrame
			end
		end
	elseif obj:IsA("Model") then
		local cf, s = obj:GetBoundingBox()
		local modelPivot = obj:GetPivot()

		local trueModelCF = cf * (modelPivot - modelPivot.Position):Inverse()
		local pos = trueModelCF.p

		return pos, trueModelCF
	elseif obj:IsA("BasePart") then
		return obj.Position, obj.CFrame
	end
end

-- Utility Methods

-- Check if a CFrame is within the ScreenBounds of our GameCamera.
-- ScreenBounds will always be relative to the GameCamera map itself (set by GameCamera.Origin)
local debugTime = os.time()

function GameCamera:checkPointInBounds(cf)
	if not cf then
		return false
	end

	local function checkVector(axis, vectors, origin)
		local min, max = vectors.Min, vectors.Max
		local relativePosition = cf:ToObjectSpace(origin):Inverse()

		local checkMin = relativePosition[axis] <= min
		local checkMax = relativePosition[axis] >= max

		if checkMin or checkMax then
			return false
		else
			return true
		end
	end

	local check = false
	local origin = self.Origin

	for axis, vectors in pairs(self.screenBounds) do
		check = checkVector(axis, vectors, origin)
		if not check then
			break
		end
	end

	-- DEBUGGING. DONT REMOVE JUST YET.
	if os.time() - debugTime > 0.1 then
		debugTime = os.time()
	end

	return check
end

-- Check if a BasePart is within Bounds of GameCamera
-- This is decided using the screenBounds table, the studs described there are relative to GameCamera.Origin.
function GameCamera:checkPointInBoundsBasePart(basePart)
	if not basePart then
		return true
	end

	local inBounds = self:checkPointInBounds(basePart.CFrame)

	return inBounds
end

-- Gets a table count of everything in GameCamera.Objects
function GameCamera:getHeadCount()
	local _count = 0

	for _, _ in pairs(self.Objects) do
		_count += 1
	end

	return _count
end

-- Connect to the PlayerAdded / PlayerRemoving events.
-- Should never really be used in-game. These will be hooked up to Signals.
function GameCamera:ConnectPlayers()
	Players.PlayerAdded:Connect(function(newPlayer)
		self:addObject(newPlayer)
	end)
	Players.PlayerRemoving:Connect(function(oldPlayer)
		self:removeObject(oldPlayer)
	end)
end

-- Get a loose focal point for the Camera to look at.
-- This will favor the current LocalPlayer.
-- Can be turned off in GameCamera.FavorPlayer
function GameCamera:getLooseFocus(lookat)
	local player = game.Players.LocalPlayer
	local focusPoint = self.Origin.p

	local character = player.Character

	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = hrp.Position
			local checkinBounds = self:checkPointInBounds(CFrame.new(pos))

			if checkinBounds then
				focusPoint = pos
			end
		end
	end

	return lookat:Lerp(focusPoint, 0.05) -- Really slight.
end

-- Get minimum and maximum vectors from Object list.
function GameCamera:getObjectsBounds()
	local objectsToIterate = self.Objects
	local positions = {}

	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

	for i, v in pairs(objectsToIterate) do
		local currentVector, currentCFrame = self.getPositionAndCFrame(v)

		if currentCFrame then
			if self:checkPointInBounds(currentCFrame) then
				table.insert(positions, currentVector)
			end
		end
	end

	for _, point in pairs(positions) do
		minX = math.min(minX, point.X)
		minY = math.min(minY, point.Y)
		minZ = math.min(minZ, point.Z)
		maxX = math.max(maxX, point.X)
		maxY = math.max(maxY, point.Y)
		maxZ = math.max(maxZ, point.Z)
	end

	return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
end

-- Averages all Player Positions together to get a lookAt Vector.
-- Returns Vector and Magnitude (distance the Camera should be from the screen based on screen AspectRatio)
function GameCamera:getLookAtAverage()
	--warn("Object", self.Objects)
	local objects = self.Objects
	local num = GameCamera:getHeadCount()
	local min, max = self:getObjectsBounds()

	local magnitude = 20

	local totalVector = Vector3.new()
	local viewportSize = workspace.CurrentCamera.ViewportSize

	-- Calculate our magnitude (only if we have more than one object. If one object, Maxmimum Vector will equal Minimum Vector)
	if max ~= min then
		local worldMagnitude = (max - min).Magnitude
		local aspectRatio = (viewportSize.Y / viewportSize.X)

		magnitude = worldMagnitude * aspectRatio
	end

	-- Check if we are trying to set the Magnitude way too far out.
	if magnitude > self.cameraMaxDistance then
		if magnitude == math.huge then
			magnitude = 20
		else
			magnitude = self.cameraMaxDistance
		end
	end

	-- Iterate through the objects we want to render in the camera.
	for i, v in pairs(objects) do
		local vector, cf = GameCamera.getPositionAndCFrame(v)
		local check = self:checkPointInBounds(cf)

		if check then
			totalVector += vector
		else
			num -= 1
		end
	end

	-- Nothing was found to be registered byt he camera.
	if num == 0 then
		totalVector = self.Origin.p
		num = 1
	end

	return (totalVector / num), magnitude * 2
end

return GameCamera
