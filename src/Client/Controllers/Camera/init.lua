local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Library.Signal)

local Camera = Knit.CreateController({
	Name = "Camera",
	States = {},

	ListenToGameCamera = Signal.new(),
})

-- Unprotected method. Use only after Start method.
-- Set the State of the Camera.
-- Uses CameraStack for further overhead management.
function Camera:SetState(state, ...)
	-- Deal with current state.
	local cameraStackController = Knit.GetController("CameraStackController")

	-- Find our Camera state.
	local stateString = state .. "Camera"
	local newState = require(script.States:FindFirstChild(state .. "Camera"))

	--[[if state == "Default" then
		cameraStackController:SetDoNotUseDefaultCamera(false)
	else
		cameraStackController:SetDoNotUseDefaultCamera(true)
	end--]]

	if self.States[stateString] then
		local camera = self.States[stateString].Camera

		if camera then
			cameraStackController:Remove(camera)
		end
	end

	if newState then
		local cameraObj = self.States[stateString]

		if not cameraObj then
			local cameraState = newState.new(...) -- Game Camera needs to return its object, which it does her
			cameraObj = { State = cameraState, Camera = nil }

			self.States[stateString] = cameraObj
		end

		local impulse = cameraStackController:GetImpulseCamera() -- Add Impulse to each camera so that we can always have some sort of Shake control.
		local camera = (cameraObj.State + impulse):SetMode("Relative") -- Impulse Camera used for shake effects.

		self.States[stateString].Camera = camera

		cameraStackController:Add(camera)

		self._currentState = self.States[stateString]
	end
end

function Camera:KnitStart()
	local CameraStackController = Knit.GetController("CameraStackController")
	local GameService = Knit.GetService("GameService")

	GameService.SetCameraState:Connect(function(...)
		self:SetState(...)
	end)

	--[[ Test for Rebinding / Binding Camera Render. 
	repeat
		task.wait(2)
		cameraStackController:SetDoNotUseDefaultCamera(not cameraStackController._doNotUseDefaultCamera)
	until 2 == 3
	--]]

	--[[ Test for Impulse Camera SummedCamera with GameCamera. 
	repeat
		task.wait(1)
		impulse:Impulse(Vector3.new(3.5 * (math.random() - 0.5), math.random(-3, 3), 3.5 * (math.random() - 0.5)))
	until 2 == 3--]]
end

function Camera:KnitInit() end

return Camera
