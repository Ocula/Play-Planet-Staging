-- @quenty / ported to Knit w/ updates @ocula
--[=[
	Holds camera states and allows for the last camera state to be retrieved. Also
	initializes an impulse and default camera as the bottom of the stack. Is a singleton.

	@class CameraStackController (previously CameraStackService by @quenty)
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

assert(RunService:IsClient(), "[CameraStackController] - Only require CameraStackController on client")

local Knit = require(ReplicatedStorage.Packages.Knit)
local CameraStackController = Knit.CreateController({
	Name = "CameraStackController",

	_doNotUseDefaultCamera = false,
})

-- Dependencies
local Maid = require(Knit.Library.Maid)
local CameraStack = require(Knit.Modules.CameraStack)
local DefaultCamera = require(Knit.Modules.DefaultCamera)
local ImpulseCamera = require(Knit.Modules.ImpulseCamera)
local Signal = require(Knit.Library.Signal)

--[=[
  Starts the CameraStack.
  
  TODO: Allow rebinding @Quenty √√√ (@Ocula completed)
		- Restructured the CameraStackService so that Start() is only handled using Signals.
		- Signals are now connected in CameraStackController:KnitInit() so that they are Top-Class priority.
		- Camera can now be unbound from Default Camera and Rebound to CameraStack throughout runtime.
	
  TODO: Handle Camera being deleted. 
		- I believe this won't need to create the new camera.
		- Meaning it may not need to handle anything, as Workspace.CurrentCamera will add everything together for us.
]=]
function CameraStackController:KnitStart()
	self._started = true

	--self.Bind:Fire(self._doNotUseDefaultCamera)
end

--[=[
	Initializes a new camera stack. Have to Initialize it manually. 
]=]
function CameraStackController:KnitInit()
--[[	self._maid = Maid.new()
	self._key = HttpService:GenerateGUID(false)

	self._cameraStack = CameraStack.new()

	-- Initialize default cameras
	self._rawDefaultCamera = DefaultCamera.new()
	self._maid:GiveTask(self._rawDefaultCamera)

	self._impulseCamera = ImpulseCamera.new()
	self._defaultCamera = (self._rawDefaultCamera + self._impulseCamera):SetMode("Relative")

	-- Add Signals
	self.CameraDestroyed = Signal.new()
	self.Bind = Signal.new()

	local function bindCameraToService()
		if self._propertyChanged then
			self._propertyChanged:Disconnect()
		end

		self._rawDefaultCamera:UnbindFromRenderStep()

		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

		self._propertyChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		end)
	end

	local function bindCameraToDefault()
		if self._propertyChanged then
			self._propertyChanged:Disconnect()
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

		self._rawDefaultCamera:BindToRenderStep()
	end

	self.Bind:Connect(function(bool)
		if bool then
			bindCameraToService()
		else
			bindCameraToDefault()
		end
	end)

	self.CameraDestroyed:Connect(function() end)

	-- Add camera to stack
	self:Add(self._defaultCamera)

	RunService:BindToRenderStep(
		"CameraStackUpdateInternal" .. self._key,
		Enum.RenderPriority.Camera.Value + 75,
		function()
			debug.profilebegin("CameraStackController")

			local state = self:GetTopState()
			local camera = self:GetTopCamera()

			if state then
				state:Set(workspace.CurrentCamera)
			end

			if camera then
				if camera.Render then
					camera:Render()
				end
			end

			debug.profileend()
		end
	)

	--[[self._maid:GiveTask(function()
		RunService:UnbindFromRenderStep("CameraStackUpdateInternal" .. self._key)
	end)--]]
end

--[=[
	Prevents the default camera from being used
	@param doNotUseDefaultCamera boolean
]=]
function CameraStackController:SetDoNotUseDefaultCamera(doNotUseDefaultCamera)
	if self._doNotUseDefaultCamera ~= doNotUseDefaultCamera then
		self.Bind:Fire(doNotUseDefaultCamera)
	end

	self._doNotUseDefaultCamera = doNotUseDefaultCamera
end

--[=[
	Pushes a disable state onto the camera stack
	@return function -- Function to cancel disable
]=]
function CameraStackController:PushDisable()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:PushDisable()
end

--[=[
	Outputs the camera stack. Intended for diagnostics.
]=]
function CameraStackController:PrintCameraStack()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:PrintCameraStack()
end

--[=[
	Returns the default camera
	@return SummedCamera -- DefaultCamera + ImpulseCamera
]=]
function CameraStackController:GetDefaultCamera()
	assert(self._defaultCamera, "Not initialized")

	return self._defaultCamera
end

--[=[
	Returns the impulse camera. Useful for adding camera shake.

	Shaking the camera:
	```lua
	self._CameraStackController:GetImpulseCamera():Impulse(Vector3.new(0.25, 0, 0.25*(math.random()-0.5)))
	```

	You can also sum the impulse camera into another effect to layer the shake on top of the effect
	as desired.

	```lua
	-- Adding global custom camera shake to a custom camera effect
	local customCameraEffect = ...
	return (customCameraEffect + self._CameraStackController:GetImpulseCamera()):SetMode("Relative")
	```

	@return ImpulseCamera
]=]
function CameraStackController:GetImpulseCamera()
	assert(self._impulseCamera, "Not initialized")

	return self._impulseCamera
end

--[=[
	Returns the default camera without any impulse cameras
	@return DefaultCamera
]=]
function CameraStackController:GetRawDefaultCamera()
	assert(self._rawDefaultCamera, "Not initialized")

	return self._rawDefaultCamera
end

--[=[
	Gets the camera current on the top of the stack
	@return CameraEffect
]=]
function CameraStackController:GetTopCamera()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetTopCamera()
end

--[=[
	Retrieves the top state off the stack at this time
	@return CameraState?
]=]
function CameraStackController:GetTopState()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetTopState()
end

--[=[
	Returns a new camera state that retrieves the state below its set state.

	@return CustomCameraEffect -- Effect below
	@return (CameraState) -> () -- Function to set the state
]=]
function CameraStackController:GetNewStateBelow()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetNewStateBelow()
end

--[=[
	Retrieves the index of a state
	@param state CameraEffect
	@return number? -- index

]=]
function CameraStackController:GetIndex(state)
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetIndex(state)
end

--[=[
	Returns the current stack.

	:::warning
	Do not modify this stack, this is the raw memory of the stack
	:::

	@return { CameraState<T> }
]=]
function CameraStackController:GetRawStack()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetRawStack()
end

--[=[
	Gets the current camera stack

	@return CameraStack
]=]
function CameraStackController:GetCameraStack()
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:GetStack()
end

--[=[
	Removes the state from the stack
	@param state CameraState
]=]
function CameraStackController:Remove(state)
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:Remove(state)
end

--[=[
	Adds the state from the stack
	@param state CameraState
]=]
function CameraStackController:Add(state)
	assert(self._cameraStack, "Not initialized")

	return self._cameraStack:Add(state)
end

function CameraStackController:Destroy()
	self._maid:DoCleaning()
end

return CameraStackController
