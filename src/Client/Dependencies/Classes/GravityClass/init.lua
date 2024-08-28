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

local Quaternion = require(ReplicatedStorage.Shared:WaitForChild("Quaternion"))

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

	self.Humanoid = player.Character:WaitForChild("Humanoid")

	player.Character.HumanoidRootPart.Anchored = true 

	self.SpawnPoint = player.Character:GetPivot() 
	self.Character = player.Character 

	self._gravityUp = UNIT_Y
	self._characterMass = 0

	self._cancelPush = Signal.new() 
	self._cancelJump = Signal.new() 

	self._camera = Camera.new(self)
	self._control = Control.new(self)
	self._collider = Collider.new(self)

	self._setRollTime = 1.2

	self.CharacterRoot = player.Character:FindFirstChild("HumanoidRootPart") 
	self.HRP = self._collider.Sphere
	self.ControllerObject = self._collider.Model 

	-- Dash/Roll/Jump Force 
	local ControlsAttachment = Instance.new("Attachment") 
	ControlsAttachment.Name = "Controls"
	ControlsAttachment.Parent = self.HRP 

	local ControlForce = Instance.new("VectorForce")
	ControlForce.Parent = self.HRP 
	ControlForce.Attachment0 = ControlsAttachment 
	ControlForce.Force = Vector3.new() 

	local JumpForce = Instance.new("VectorForce")
	JumpForce.Parent = self.HRP 
	JumpForce.Attachment0 = ControlsAttachment 
	JumpForce.Force = Vector3.new()
	
	self.ControlForce = ControlForce 
	self.JumpForce = JumpForce 

	self._fallStart = self.HRP.Position.y
	self._prevPart = workspace.Terrain
	self._prevCFrame = CFrame.new()

	local AnchorAttachment = Instance.new("Attachment") 
	AnchorAttachment.Parent = self.CharacterRoot 
	AnchorAttachment.Position = Vector3.new(0, -self.Humanoid.HipHeight, 0)
	AnchorAttachment.Name = "Anchor" 

	self.AnchorAttachment = AnchorAttachment

	local AnchorPosition = Instance.new("AlignPosition") 
	AnchorPosition.Parent = self.CharacterRoot
	AnchorPosition.Attachment0 = AnchorAttachment
	AnchorPosition.RigidityEnabled = false
	AnchorPosition.Enabled = false 
	AnchorPosition.MaxForce = math.huge 
	AnchorPosition.Responsiveness = 200
	AnchorPosition.Mode = Enum.PositionAlignmentMode.OneAttachment

	local AlignOrientation = Instance.new("AlignOrientation") 
	AlignOrientation.Parent = self.CharacterRoot 
	AlignOrientation.Responsiveness = 200
	AlignOrientation.Enabled = false 
	AlignOrientation.MaxTorque = 100000000
	AlignOrientation.Attachment0 = AnchorAttachment
	AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment 
	--AlignOrientation.Attachment1 = self.HRP:FindFirstChild("Align")  

	self.AnchorPosition = AnchorPosition
	self.AnchorOrientation = AlignOrientation 

	self.StateTracker = StateTracker.new(self)
	self.Maid = Maid.new()

	init(self)

	return self
end

function GravityControllerClass:Dash()
	self._cancelJump:Fire() 

	local velocity = self.HRP.Velocity 
	local localVelocity = self.HRP.CFrame:VectorToObjectSpace(velocity) 

	self.HRP.Velocity = self.HRP.CFrame:VectorToWorldSpace(Vector3.new(0, 0, localVelocity.Z)) -- neutralize hrp 

	--self.JumpForce.Force = Vector3.new(0, (self._characterMass * workspace.Gravity) * 0.8, 0)

	self:Push(18, Vector3.new(0, 0, -1), 1, 0.5, 0):Wait()

	--self.JumpForce.Force = Vector3.new() 
end 

function GravityControllerClass:Roll()
	self._cancelJump:Fire() 

	local velocity = self.HRP.Velocity 
	local localVelocity = self.HRP.CFrame:VectorToObjectSpace(velocity) 

	self.HRP.Velocity = self.HRP.CFrame:VectorToWorldSpace(Vector3.new(localVelocity.X, 0, localVelocity.Z)) -- neutralize hrp 

	self:Push(12, Vector3.new(0, 0, -1), 0.5, function(decay)
		local _connect 
		local decayed = false 
		
		_connect = self._collider.OnGrounded:Connect(function()
			decayed = true 

			if _connect then 
				_connect:Disconnect() 
			end 

			decay() 
		end)

		task.delay(0.8, function()
			if not decayed then 
				_connect:Disconnect()
				decayed = true 
			end 

			decay() 
		end)
	end, 0, true):Wait()
end 

function GravityControllerClass:Push(
		Speed: number, 
		Direction: Vector3, 
		Suspension: number?, 
		Decay: any?, 
		SimulateFriction: number?, 
		canBeLongJump: boolean
	) -- Direction is a unitary direction vector for push direction.

	self._cancelPush:Fire() 

	local Player = game.Players.LocalPlayer

	-- set control force 
	local _signal = Signal.new() 
	local isCancelled = false 
 
	local cancelListen = self._cancelPush:Connect(function()
		isCancelled = true 
	end)

	local weight = self._characterMass * workspace.Gravity
	local force = weight * Speed 
	local pushForce = Direction * force
	local frictionCoefficient = (SimulateFriction or 0)

	local function brake(alpha)
		local dt = RunService.RenderStepped:Wait() 

		local localVelocity = self.HRP.CFrame:VectorToObjectSpace(self.HRP.Velocity)
		local frictionForce = -((weight * Direction) * frictionCoefficient)
	
		self.ControlForce.Force = self.ControlForce.Force:lerp(Vector3.new(), alpha) + frictionForce--pushForce:lerp(Vector3.new(), i/steps) + Vector3.new(0, weight * (Suspension or .5), 0)

		local baseSpeed = 0.1

		--warn("Walk Magnitude:", localVelocity.Magnitude) 

		if math.abs(localVelocity.Magnitude) <= 6 then 
			Player:SetAttribute("isRolling", nil) 
			Player:SetAttribute("isLongJumping", nil) 
			Player:SetAttribute("isDashing", nil) 
		end 

		if math.abs(localVelocity.Magnitude) <= baseSpeed then 
			isCancelled = true 
		end 
	end 

	RunService.RenderStepped:Wait() 

	self.ControlForce.Force = pushForce + Vector3.new(0, weight * (Suspension or .5), 0)

	local function onDecay()
		local steps = 128

		--warn("First:", self.ControlForce.Force)

		if canBeLongJump and Player:GetAttribute("isRolling") then 
			if not self._collider:IsGrounded() then 
				warn("Long jumping!") 

				self.ControlForce.Force = (pushForce * 2) - Vector3.new(0, weight * 0.25, 0)
				
				warn("Starting loop") 

				repeat 
					--longJumpStep += 1
					task.wait(0.1)

					--brake(longJumpStep / stepCheck) 
				until self._collider:IsGrounded() or (Player:GetAttribute("isRolling") == false) or isCancelled--]]
				
				warn("Grounded... now decaying") 
			end 
		end 

		for i = 1, steps do 
			if isCancelled then break end 

			RunService.Stepped:Wait() 
			brake(i/steps)
		end

		self.ControlForce.Force = Vector3.new()

		cancelListen:Disconnect() 
		_signal:Fire() 
	end 

	if type(Decay) == "function" then 
		Decay(onDecay) 
	else 
		task.delay(Decay, onDecay) 
	end 

	return _signal 
end 

function GravityControllerClass:Jump()
	--local localVelocity = self.HRP.CFrame:VectorToObjectSpace(self.HRP.Velocity)

	local Y = Vector3.new(0, 1, 0)

	local RotationAxis = Y:Cross(self._gravityUp)
	local DotProduct = Y:Dot(self._gravityUp)
	local Angle = math.acos(DotProduct) 
	local RotationFrame = CFrame.fromAxisAngle(RotationAxis, Angle)

	if RotationAxis.Magnitude == 0 or (Angle ~= Angle) then
		if DotProduct < 0 then
			-- Vectors are anti-parallel, apply 180-degree rotation
			RotationFrame = CFrame.Angles(math.pi, 0, 0)
		else
			-- Vectors are parallel, no rotation needed
			RotationFrame = CFrame.new()
		end
	else
		-- Normal case
		RotationFrame = CFrame.fromAxisAngle(RotationAxis, Angle)
	end

	local JumpForce = RotationFrame:VectorToWorldSpace(Vector3.new(0, (self._characterMass * workspace.Gravity) / 3, 0))

	--self.HRP.Velocity = toObjectJump + localVelocity

	warn("JumpForce:", JumpForce, Angle, DotProduct)

	self.HRP.Velocity = JumpForce

	--self:Push(2.5, Vector3.new(0, 1, 0), 0)


	--[[
		Speed: number, 
		Direction: Vector3, 
		Suspension: number?, 
		Decay: any?, 
		SimulateFriction: number?, 
		canBeLongJump: boolean

	]]

	--[[
	local Player = game.Players.LocalPlayer 
	
	local kP, kI, kD = 13.5, 0.1, 0.01
	local PID = require(script.Utility.PID).new(kP, kI, kD)

	local targetUpSpeed = self.Humanoid.JumpPower * JUMP_MODIFIER
	local startJump = tick() 
	local cancelJump
	local jumpBind

	local isDashing = Player:GetAttribute("isDashing") 
	local complete = false 

	local function stopJump()
		if complete then return end 

		complete = true 

		if cancelJump then 
			cancelJump:Disconnect() 
		end 
		
		if jumpBind then 
			jumpBind:Disconnect()
		end 

		self.JumpForce.Force = Vector3.new() 
	end 

	cancelJump = self._cancelJump:Connect(function()
		stopJump() 
	end)

	jumpBind = game:GetService("RunService").RenderStepped:Connect(function(dt: number)
		if complete then 
			return 
		end 

		-- wait for not grounded:
		if not self._collider:IsGrounded() then 
			-- check for long jump 
			if Player:GetAttribute("isRolling") then 
				Player:SetAttribute("isLongJumping", true) 
			end 
		end 

		local nowDashing = Player:GetAttribute("isDashing") 

		if not isDashing and nowDashing then 
			stopJump() 
			return 
		end

		local currentVelocity = self.HRP.Velocity
		local upSpeed = currentVelocity:Dot(self._gravityUp)
		local pidUpSpeed = PID:Update(targetUpSpeed, upSpeed, dt) * (self._characterMass ^ 2)

		self.JumpForce.Force = Vector3.new(0, pidUpSpeed, 0)

		if tick() - startJump > 0.22 then 
			stopJump() 
		end 
	end)--]]
end 

function GravityControllerClass:GetPosition()
	return self._collider.Sphere.Position
end 

-- Debug
local draw = require(ReplicatedStorage.Shared.Octree.Draw) 
local baseRay = Ray.new(Vector3.new(0,0,0), Vector3.new(0,1,0))

local rightPart = draw.ray(baseRay, Color3.new(1,0,0))
local upPart = draw.ray(baseRay, Color3.new(0,1,0))
local lookPart = draw.ray(baseRay, Color3.new(0,0,1))

local debugCam = Instance.new("Camera") 

function updateDebugVector(right, up, look) 
	local plr = game.Players.LocalPlayer 
	local pgui = plr:WaitForChild("PlayerGui")
	local deb = pgui:WaitForChild("Debug")	
	local vectorFrame = deb:WaitForChild("Vector") 

	local vFrame = vectorFrame:WaitForChild("ViewportFrame")
	local wModel = vFrame:WaitForChild("WorldModel") 

	local hrp = plr.Character:WaitForChild("HumanoidRootPart")

	rightPart.Parent = wModel
	upPart.Parent = wModel 
	lookPart.Parent = wModel 

	debugCam.Parent = wModel 
	vFrame.CurrentCamera = debugCam 

	debugCam.CFrame = CFrame.new((hrp.CFrame * CFrame.new(0, -10, 0)).Position, hrp.Position) 

	draw.updateRay(lookPart, Ray.new(hrp.Position, look)) 
	draw.updateRay(rightPart, Ray.new(hrp.Position, right)) 
	draw.updateRay(upPart, Ray.new(hrp.Position, up)) 
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

	local Player = game.Players.LocalPlayer 

	local LastJump = Player:GetAttribute("LastJump") or 0
	local JumpsLeft = Player:GetAttribute("JumpsLeft")
 	local MaxJumpsLeft = Player:GetAttribute("MaxJumpsLeft") 

	if (tick() - LastJump > 0.32) and JumpsLeft > 0 and not Player:GetAttribute("isDashing") then
		warn("Jump requested!") 

		if Player:GetAttribute("isRolling") and not (JumpsLeft > MaxJumpsLeft - 2) then -- only jump once 
			return
		end--]]

		Player:SetAttribute("JumpsLeft", JumpsLeft - 1)
		JumpsLeft -= 1 

		if JumpsLeft == MaxJumpsLeft - 1 then 
			self.StateTracker:RequestJump()
		end 

		warn("Jumping!")

		self:Jump() 

		Player:SetAttribute("LastJump", tick())

		--[[--]]
	end
end

local function lerp(a, b, t) 
	return a + (b - a) * t
end 

local function onDashRequest(self)
	local Player = game.Players.LocalPlayer 

	local LastDash = Player:GetAttribute("LastDash") or 0
	local DashPower = Player:GetAttribute("DashPower") or 1
	local DashesLeft = Player:GetAttribute("DashesLeft")
	local MaxDashesLeft = Player:GetAttribute("MaxDashesLeft")

	if DashesLeft > 0 and not Player:GetAttribute("isDashing") then
		warn("DASHING!") 
		Player:SetAttribute("isDashing", true) 
		Player:SetAttribute("DashesLeft", DashesLeft - 1)

		DashesLeft -= 1 

		self:Dash()
		--self:Push(0.7, Vector3.new(0,0,-1), 1):Wait()

		Player:SetAttribute("isDashing", false) 
		Player:SetAttribute("LastDash", tick())
	end
end

-- https://create.roblox.com/docs/reference/engine/datatypes/PhysicalProperties
local function getActualFriction(partA, partB)
	return (partA.CurrentPhysicalProperties.Friction * partA.CurrentPhysicalProperties.FrictionWeight + partB.CurrentPhysicalProperties.Friction * partB.CurrentPhysicalProperties.FrictionWeight) / (partA.CurrentPhysicalProperties.FrictionWeight + partB.CurrentPhysicalProperties.FrictionWeight)
end

local function getAngle(v1,v2)
	return math.atan2((v1:Cross(v2)).Magnitude,v1:Dot(v2))
end

local function onRollRequest(self)
	local Player = game.Players.LocalPlayer 

	if not Player:GetAttribute("isRolling") then
		Player:SetAttribute("isRolling", true)

		warn("Rolling!") 

		self:Roll() 

		Player:SetAttribute("isRolling", false) 
		Player:SetAttribute("LastRoll", tick())
	end
end 

local function onLongJumpRequest(self) 
	warn("Long jumping!") 

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

-- What we can do is translate the camCF to a UNIT vector
-- Then translate it back to our abritrary vector. 
local rightPlaneRay = draw.ray(Ray.new(Vector3.new(), Vector3.new(1,0,0)), Color3.new(1,0,0), workspace, 1)
local forwardPlaneRay = draw.ray(Ray.new(Vector3.new(), Vector3.new(0,0,1)), Color3.new(0,0,1), workspace, 1)
local upPlaneRay = draw.ray(Ray.new(Vector3.new(), Vector3.new(0,1,0)), Color3.new(0,1,0), workspace, 1)

local testPart = Instance.new("Part", workspace)
testPart.Size = Vector3.new(3,5,3) 
testPart.Anchored = true 

local alignatt = Instance.new("Attachment")
alignatt.Parent = testPart 

local alignor = Instance.new("AlignOrientation")
alignor.Parent = testPart 
alignor.Attachment0 = alignatt 
alignor.RigidityEnabled = true 
alignor.Mode = Enum.OrientationAlignmentMode.OneAttachment

local alignpos = Instance.new("AlignPosition")
alignpos.Parent = testPart 
alignpos.Attachment0 = alignatt 
alignpos.RigidityEnabled = true 
alignpos.Mode = Enum.PositionAlignmentMode.OneAttachment

function getCharRotation(look, up)
	local rightVector = look:Cross(up).Unit 
	local forward = rightVector:Cross(up).Unit 

	return rightVector, forward 
end 

local function calculateLerpedUpVector(currentUpVector, movementDirection, maxTilt, speed, maxSpeed)
    -- Calculate the tilt angle based on movement speed
    local tiltAngle = math.min(speed / maxSpeed * maxTilt, maxTilt)
    
    -- Calculate the tilt direction (perpendicular to the upvector and the movement direction)
    local tiltDirection = currentUpVector:Cross(movementDirection.Unit)
    
    -- Create a CFrame that represents the tilt
    local tiltCFrame = CFrame.fromAxisAngle(tiltDirection, math.rad(tiltAngle))
    
    -- Apply the tilt to the upvector
    local tiltedUpVector = tiltCFrame:VectorToWorldSpace(currentUpVector)
    
    -- Lerp between the current upvector and the tilted upvector
    local lerpedUpVector = currentUpVector:Lerp(tiltedUpVector, tiltAngle / maxTilt)
    
    return tiltCFrame 
end

local function angleBetweenVectors(v1, v2)
    local dot = v1:Dot(v2)
    local det = v1:Cross(v2).Magnitude
    return math.atan2(det, dot)
end

function getLookVector(pitch, yaw, up) 
	-- Convert pitch and yaw to radians
	pitch = math.rad(pitch)
	yaw = math.rad(yaw)

	-- Calculate the LookVector
	local x = math.cos(pitch) * math.sin(yaw)
	local y = math.sin(pitch)
	local z = math.cos(pitch) * math.cos(yaw)
	local lookVector = Vector3.new(x, y, z)

	-- Rotate the LookVector to be relative to the UpVector
	local rightVector = lookVector:Cross(up).Unit
	lookVector = up:Cross(rightVector).Unit

	return lookVector 
end

-- For our "fake" character
local function getPlayerPositionAndRotation(self, forwardVector, desiredPosition) 
	local GravityController = Knit.GetController("GravityController") 
	local Field = GravityController.Field 

	if Field then 
		local Object = GravityController.Fields[Field] 

		if Object then
			local AnchorPos = self.AnchorPosition.Position
			local AnchorOri = self.AnchorOrientation.CFrame

			local Position = ((CFrame.new(AnchorPos) * AnchorOri) * CFrame.new(0, -self.Humanoid.HipHeight, 0)).Position--self.HRP.Position
            local Normal, Result = Object:GetNormal(Position)

			if Normal and Result then 
            
				-- Calculate the up vector from the normal
				local UpVector = Normal.unit
				local GravityUp = self._gravityUp 

				local angle = math.deg(angleBetweenVectors(UpVector, GravityUp))

				if angle > 60 then
					UpVector = GravityUp 
				end
				
				-- Determine the forward vector for the player's orientation
				local ForwardVector = forwardVector
				
				-- Ensure the forward vector is perpendicular to the up vector
				local RightVector = ForwardVector:Cross(UpVector).unit
				ForwardVector = UpVector:Cross(RightVector).unit
				
				-- Create a rotation CFrame from the up and forward vectors
				local Point = CFrame.fromMatrix(Result.Position, RightVector, UpVector)
				
				return Point

			end
		end 
	end 
end 

local function onGravityStep(self, dt)
	local camCF = workspace.CurrentCamera.CFrame
	local pitchYaw = self._camera.CameraModule:GetPitchYaw()

	-- update the gravity vector
	local oldGravity = self._gravityUp
	local newGravity = self:GetGravityUp(oldGravity)

	local sphericalArc = getRotationBetween(oldGravity, newGravity, camCF.XVector)
	local lerpedArc = CFrame.new():Lerp(sphericalArc, TRANSITION)

	self._gravityUp = lerpedArc * oldGravity

	-- get world move vector
	local fDot = getLookVector(pitchYaw.X, pitchYaw.Y, newGravity):Dot(newGravity)
	local cForward = math.abs(fDot) > 0.5 and math.sign(fDot)*camCF.YVector or -camCF.ZVector
	
	local left = -cForward:Cross(newGravity).Unit
	local forward = -left:Cross(newGravity).Unit

	local move = self._control:GetMoveVector()

	if move.Magnitude == 0 then 
		move = self.Humanoid:GetAttribute("MoveDirection") or Vector3.new()
	end 

	local worldMove = forward*move.z - left*move.x
	
	local isInputMoving = false
	local length = worldMove.Magnitude

	local player = game.Players.LocalPlayer 

	if length > 0 then
		isInputMoving = true
		worldMove = worldMove / length

		if player:GetAttribute("isRolling") or player:GetAttribute("isDashing") or player:GetAttribute("isLongJumping")  then 
			worldMove *= 0.05

			--dVelocity = dVelocity * 0.1
			--dVelocityM = dVelocity.Magnitude
		end--]]
		
	end

	-- get the desired character cframe
	local hrpLook = -self.HRP.CFrame.ZVector
	local charForward = hrpLook:Dot(forward)*forward + hrpLook:Dot(left)*left
	local charRight = charForward:Cross(newGravity).Unit

	local newCharRotation = CFrame.new()
	local newCharCF = CFrame.fromMatrix(ZERO3, charRight, newGravity, -charForward)

	if self._camera.CameraModule:IsCamRelative() then
		newCharCF = CFrame.fromMatrix(ZERO3, -left, newGravity)
	elseif isInputMoving then

		newCharRotation = newCharRotation:Lerp(getRotationBetween(
			charForward,
			worldMove,
			newGravity
		), 0.3) --* TiltCFrame
	end

	-- calculate forces
	local g = workspace.Gravity
	local gForce = g * self._characterMass * (UNIT_Y - newGravity)

	local cVelocity = self.HRP.Velocity
	local tVelocity = self.Humanoid.WalkSpeed * worldMove
	local gVelocity = cVelocity:Dot(newGravity) * newGravity
	local hVelocity = cVelocity - gVelocity

	if hVelocity:Dot(hVelocity) < 1 then
		hVelocity = ZERO3
	end

	local dVelocity = tVelocity - hVelocity
	local dVelocityM = dVelocity.Magnitude

	local walkForceM = math.min(10000, WALK_FORCE * self._characterMass * dVelocityM / (dt*60))
	local walkForce = walkForceM > 0 and (dVelocity / dVelocityM) * walkForceM or ZERO3

	local charRotation = newCharRotation * newCharCF

	--self.ControlForce.Force = self.ControlForce.Force:lerp(self.TargetForce or Vector3.new(), 0.2)

	self.StateTracker:Update(self._gravityUp, self._collider:IsGrounded(false), isInputMoving)
	self._collider:Update(walkForce, gForce, charRotation)

	-- character aesthetics
	--local CurrentPosition = self.AnchorPosition.Position:lerp(self._collider.Sphere.Position, 1)
	--local CurrentRotation = self.AnchorOrientation.CFrame:lerp(charRotation, 0.4) 

	local Point = getPlayerPositionAndRotation(self, charForward) 

	if Point then 
		--self.AnchorPosition.Position = Point.Position:lerp(self._collider.Sphere.Position, 0.4)
		--self.AnchorOrientation.CFrame = Point
	else 
		--self.AnchorPosition.Position = self._collider.Sphere.Position 
		--self.AnchorOrientation.CFrame = charRotation 
	end

	self.LastForward = charForward 
end

function init(self)
	self.Maid:Mark(self._camera)
	self.Maid:Mark(self._control)
	self.Maid:Mark(self._collider)

	self._characterMass = getModelMass(self.ControllerObject)
	
	self.Maid:Mark(self.ControllerObject.ChildRemoved:Connect(function()
		self._characterMass = getModelMass(self.ControllerObject)
	end))

	self.Humanoid.PlatformStand = true

	local function check(attribute)
		local Player = game.Players.LocalPlayer 
		return Player:GetAttribute(attribute) 
	end 

	self.Maid:Mark(self.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if self.Humanoid.Jump then
			if check("isRolling") then 
				--warn("Long jump request!")
				if not check("isLongJumping") then 
					onJumpRequest(self)
				end
			else
				onJumpRequest(self)
			end 

			self.Humanoid.Jump = false
		end
	end))

	local CAS = game:GetService("ContextActionService")

	local function handleAction(actionName, inputState, inputObject)
		if actionName == "DashRoll" then 
			if inputState == Enum.UserInputState.Begin then 
				local isGrounded = self._collider:IsGrounded(true)

				if isGrounded then 
					warn("Roll request!") 
					onRollRequest(self)
				else 
					warn("Dash request!") 
					onDashRequest(self) 
				end 
			end 
		end
	end 

	CAS:BindAction("DashRoll", handleAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)

	self.Maid:Mark(self.StateTracker.Changed:Connect(function(state, speed)
		if state == Enum.HumanoidStateType.Freefall then
			self._fallStart = self.HRP.Position:Dot(self._gravityUp)
		end
	end))

	self.Maid:Mark(RunService.Heartbeat:Connect(function(dt)
		onHeartbeat(self, dt)
	end))

	self.Maid:Mark(self._collider.OnGrounded:Connect(function(isGrounded: boolean)
		local Player = game.Players.LocalPlayer 

		if isGrounded then 
			local MaxDashesLeft = Player:GetAttribute("MaxDashesLeft") 
			local MaxJumpsLeft = Player:GetAttribute("MaxJumpsLeft") 

			Player:SetAttribute("isLongJumping", nil) 

			Player:SetAttribute("DashesLeft", MaxDashesLeft)
			Player:SetAttribute("JumpsLeft", MaxJumpsLeft) 
		end 
	end))

	RunService:BindToRenderStep("GravityStep", Enum.RenderPriority.First.Value, function(dt)
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
	local GravityController = Knit.GetController("GravityController") 

	return GravityController:GetGravityUp() or oldGravity
end

function GravityControllerClass:GetMoveVector()
	return self._control:GetMoveVector()
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