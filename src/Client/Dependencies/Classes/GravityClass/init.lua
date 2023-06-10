local RunService = game:GetService("RunService")
local CharacterModules = script:WaitForChild("CharacterModules")

-- Dependencies
local Camera = require(CharacterModules.Camera)
local Control = require(CharacterModules.Control) 
local Collider = require(script.Collider)

local Maid = require(script.Utility.Maid)

local StateTracker = require(script.StateTracker)
local Signal = require(script.Utility.Signal)

-- CONSTANTS

local TRANSITION = 0.15
local WALK_FORCE = 200 / 3
local JUMP_MODIFIER = 1.2

local ZERO3 = Vector3.new(0, 0, 0)
local UNIT_Y = Vector3.new(0, 1, 0)

local _counter = 0 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GravityClient 

-- Class

local GravityControllerClass = {}
GravityControllerClass.__index = GravityControllerClass
GravityControllerClass.ClassName = "GravityController"

-- Public Constructors

function GravityControllerClass.new(player)
	GravityClient = Knit.GetController("GravityController") 

	local self = setmetatable({}, GravityControllerClass)

	self.Player = player

	if not player.Character then 
		repeat 
			task.wait()
		until player.Character 
	end 
	
	self.Character = player.Character 

	self.Humanoid = player.Character:WaitForChild("Humanoid")
	self.HRP = self.Humanoid.RootPart

	self._gravityUp = UNIT_Y
	self._characterMass = 0

	self._camera = Camera.new(self)
	self._control = Control.new(self)
	self._collider = Collider.new(self)

	self._fallStart = self.HRP.Position.y
	self._prevPart = workspace.Terrain
	self._prevCFrame = CFrame.new()

	self.StateTracker = StateTracker.new(self)
	self.Maid = Maid.new()

	init(self)

	return self
end

-- Debug

function updateDebugVector(rotate) 
	local plr = game.Players.LocalPlayer 
	local deb = plr.PlayerGui:WaitForChild("Debug")

	local vec = deb.Vector
	local vFrame = vec.ViewportFrame
	local world = vFrame.WorldModel
	local part = world.CharacterRotate 

	part.WorldPivot = CFrame.new() * rotate 
end 

-- Private Methods

local function getRotationBetween(u, v, axis)
    local dot = u:Dot(v)
    local uxv = u:Cross(v)

    local tolerance = 0.00001 -- Tolerance threshold for comparing dot product

    if dot < -1 + tolerance then
        return CFrame.fromAxisAngle(axis, math.pi)
    end

    return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end


local function getModelMass(model)
	local mass = 0
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") and not part.Massless then
			mass = mass + part:GetMass()
		end
	end
	return mass
end

local function onJumpRequest(self)
	if not self.StateTracker.Jumped and self._collider:IsGrounded(true) then
		local vel = self.HRP.Velocity
		self.HRP.Velocity = vel + self._gravityUp*self.Humanoid.JumpPower*JUMP_MODIFIER
		self.StateTracker:RequestJump()
	end
end

local function onHeartbeat(self, dt)
	local standingPart = self._collider:GetStandingPart()
	
	if standingPart and self._prevPart and self._prevPart == standingPart then
		local offset = self._prevCFrame:ToObjectSpace(self.HRP.CFrame)
		self.HRP.CFrame = standingPart.CFrame * offset
	end

	self._prevPart = standingPart
	self._prevCFrame = standingPart and standingPart.CFrame
end

local function orthogonalizeCameraLookVector(lookVector, upVector)
    lookVector = lookVector.Unit
    upVector = upVector.Unit
    
    local dotProduct = lookVector:Dot(upVector)
    local projectionVector = dotProduct * upVector
    local orthogonalizedLookVector = lookVector - projectionVector
    
    return orthogonalizedLookVector.Unit
end

local function onGravityStep(self, dt)
	local camCF = workspace.CurrentCamera.CFrame

	-- update the gravity vector
	local oldGravity = self._gravityUp
	local newGravity = self:GetGravityUp(oldGravity)

	if not oldGravity or not newGravity then return end -- packet loss

	local sphericalArc = getRotationBetween(oldGravity, newGravity, camCF.XVector)
	local lerpedArc = CFrame.new():Lerp(sphericalArc, TRANSITION)

	self._gravityUp = lerpedArc * oldGravity

	-- get world move vector
	local fDot = camCF.ZVector:Dot(newGravity)
	local cForward = math.abs(fDot) > 0.5 and math.sign(fDot) * camCF.YVector or -camCF.ZVector
	
	local left = -cForward:Cross(newGravity).Unit
	local forward = -left:Cross(newGravity).Unit

	local move = self._control:GetMoveVector()
	local worldMove = forward*move.z - left*move.x
	
	local isInputMoving = false
	local length = worldMove.Magnitude

	if length > 0 then
		isInputMoving = true
		worldMove = worldMove / length
	end

	-- get the desired character cframe
	local hrpLook = -self.HRP.CFrame.ZVector
	local charForward = hrpLook:Dot(forward)*forward + hrpLook:Dot(left)*left
	local charRight = charForward:Cross(newGravity).Unit

	local newCharRotation = CFrame.new()
	local newCharCF = CFrame.fromMatrix(ZERO3, charRight, newGravity, -charForward)

	if self._camera.CameraModule:IsCamRelative() then 
		newCharRotation = newCharRotation:Lerp(CFrame.fromAxisAngle(camCF.LookVector, 0), 1)
		--newCharRotation:Lerp(CFrame.new(, 0.7)
	elseif isInputMoving then
		--warn("rotating") 
		newCharRotation = newCharRotation:Lerp(getRotationBetween(
			charForward,
			worldMove,
			newGravity
		), .7)
	end

	-- calculate forces
	local g = workspace.Gravity
	local gForce = g * self._characterMass * (UNIT_Y - newGravity)

	local cVelocity = self.HRP.Velocity
	local tVelocity = self.Humanoid.WalkSpeed * worldMove
	local gVelocity = cVelocity:Dot(newGravity)*newGravity
	local hVelocity = cVelocity - gVelocity

	if hVelocity:Dot(hVelocity) < 1 then
		hVelocity = ZERO3
	end

	local dVelocity = tVelocity - hVelocity
	local dVelocityM = dVelocity.Magnitude

	local walkForceM = math.min(10000, WALK_FORCE * self._characterMass * dVelocityM / (dt*60))
	local walkForce = walkForceM > 0 and (dVelocity / dVelocityM)*walkForceM or ZERO3

	local charRotation = newCharRotation * newCharCF

	updateDebugVector(charRotation) 

	self.StateTracker:Update(self._gravityUp, self._collider:IsGrounded(false), isInputMoving)
	self._collider:Update(walkForce + gForce, charRotation)
end

function init(self)
	self.Maid:Mark(self._camera)
	self.Maid:Mark(self._control)
	self.Maid:Mark(self._collider)

	self._characterMass = getModelMass(self.Character)
	
	self.Maid:Mark(self.Character.ChildRemoved:Connect(function()
		self._characterMass = getModelMass(self.Character)
	end))

	self.Humanoid.PlatformStand = true

	self.Maid:Mark(self.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if self.Humanoid.Jump then
			onJumpRequest(self)
			self.Humanoid.Jump = false
		end
	end))

	self.Maid:Mark(self.StateTracker.Changed:Connect(function(state, speed)
		if state == Enum.HumanoidStateType.Freefall then
			self._fallStart = self.HRP.Position:Dot(self._gravityUp)
		end
	end))

	self.Maid:Mark(RunService.Heartbeat:Connect(function(dt)
		onHeartbeat(self, dt)
	end))

	RunService:BindToRenderStep("GravityStep", Enum.RenderPriority.Character.Value - 1, function(dt)
		onGravityStep(self, dt)
	end)

	--self.Humanoid.StateChanged:Wait()
	self.StateTracker.Changed:Fire(self.StateTracker.State, 0)
end

-- Public Methods

function GravityControllerClass:ResetGravity(gravity)
	self._gravityUp = gravity
	self._fallStart = self.HRP.Position:Dot(gravity)
end

function GravityControllerClass:GetFallHeight()
	if self.StateTracker.State == Enum.HumanoidStateType.Freefall then
		local height = self.HRP.Position:Dot(self._gravityUp)
		return height - self._fallStart
	end
	return 0
end

function GravityControllerClass:GetGravityUp(oldGravity)
	return oldGravity
end

function GravityControllerClass:Destroy()
	warn("Cleaning") 
	RunService:UnbindFromRenderStep("GravityStep")
	self._camera.CameraModule:Reset() 
	self.Maid:Sweep()
	self.Humanoid.PlatformStand = false
end

--

return GravityControllerClass