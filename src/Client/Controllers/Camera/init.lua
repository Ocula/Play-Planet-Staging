-- Camera Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PatchCameraModule = ReplicatedStorage.Packages:WaitForChild("patch-cameramodule") 
local Signal = require(Knit.Library.Signal)

local Camera = Knit.CreateController({
	Name = "Camera",
	States = {},

	_internal = {},

	ListenToGameCamera = Signal.new(),
})

function Camera:GetPlayerModuleObject()
	return self._internal.PlayerModuleObject
end

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

	local CameraObject = workspace.CurrentCamera 
	CameraObject.CameraType = "Scriptable"

	local Player = game.Players.LocalPlayer 
	local playerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
	local Control = playerModule:GetControls()

	game:GetService("RunService").RenderStepped:Connect(function()
		local Character = Player.Character 

		if Character then 
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart then 
				CameraObject.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(50,0,0), HumanoidRootPart.Position)

				warn(Control:GetMoveVector())
			end 
		end 
	end)

	--

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

function Camera:KnitInit()
	--[[warn("Camera Init") 

	local Client = script.Parent:FindFirstAncestor("Client")
	local PlayerModule = Client.Parent:FindFirstChild("PlayerModule") 
	local CameraModule = PlayerModule:FindFirstChild("CameraModule")

	warn("Camera Init 2", PlayerModule, CameraModule) 

	require(PatchCameraModule)(CameraModule)

	self._internal.PlayerModuleObject = PlayerModule
	self._internal.CameraModuleObject = CameraModule 

	warn("Camera Init 3") 

	-- Run injections
	for i,v in pairs(script.Inject:GetChildren()) do
		warn("Injection:", i,v)
		local _inject = require(v)
	end

	local playerModuleObject = require(PlayerModule) 
	local cameraModuleObject = playerModuleObject:GetCameras()

	warn("Camera Set", playerModuleObject, cameraModuleObject)

	-- Now expose this to our whole framework
	self._internal.PlayerModule = playerModuleObject
	self._internal.CameraModule = cameraModuleObject--]]
end

return Camera
