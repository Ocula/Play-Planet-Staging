-- GravityCamera.lua @EgoMoose 

-- 

local transitionRate: number = 0.15

local upCFrame: CFrame = CFrame.new()
local upVector: Vector3 = upCFrame.YVector
local targetUpVector: Vector3 = upVector
local twistCFrame: CFrame = CFrame.new()

local spinPart: BasePart = workspace.Terrain
local prevSpinPart: BasePart = spinPart
local prevSpinCFrame: CFrame = spinPart.CFrame

--
local function checkVectorNaN(v3)
    if v3.X ~= v3.X or v3.Y ~= v3.Y or v3.Z ~= v3.Z then 
        return true 
    end 

    return false 
end 

local function getRotationBetween(u: Vector3, v: Vector3, axis: Vector3): CFrame
	local dot, uxv = u:Dot(v), u:Cross(v)
	if dot < -0.99999 then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

local function calculateUpStep(_dt: number)
	local axis = workspace.CurrentCamera.CFrame.RightVector

	local sphericalArc = getRotationBetween(upVector, targetUpVector, axis)
	local transitionCF = CFrame.new():Lerp(sphericalArc, transitionRate)

	upVector = transitionCF * upVector
	upCFrame = transitionCF * upCFrame
end

local function twistAngle(cf: CFrame, direction: Vector3): number
	local axis, theta = cf:ToAxisAngle()
	local w, v = math.cos(theta/2),  math.sin(theta/2) * axis
	local proj = v:Dot(direction) * direction
	local twist = CFrame.new(0, 0, 0, proj.x, proj.y, proj.z, w)
	local _nAxis, nTheta = twist:ToAxisAngle()
	return math.sign(v:Dot(direction)) * nTheta
end

local function QuaternionFromCFrame(cf)
    local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:GetComponents()
    local trace = m00 + m11 + m22

    local qw, qx, qy, qz
    if trace > 0 then
        local s = math.sqrt(1 + trace) * 2
        qw = 0.25 * s
        qx = (m21 - m12) / s
        qy = (m02 - m20) / s
        qz = (m10 - m01) / s
    elseif m00 > m11 and m00 > m22 then
        local s = math.sqrt(1 + m00 - m11 - m22) * 2
        qw = (m21 - m12) / s
        qx = 0.25 * s
        qy = (m01 + m10) / s
        qz = (m02 + m20) / s
    elseif m11 > m22 then
        local s = math.sqrt(1 + m11 - m00 - m22) * 2
        qw = (m02 - m20) / s
        qx = (m01 + m10) / s
        qy = 0.25 * s
        qz = (m12 + m21) / s
    else
        local s = math.sqrt(1 + m22 - m00 - m11) * 2
        qw = (m10 - m01) / s
        qx = (m02 + m20) / s
        qy = (m12 + m21) / s
        qz = 0.25 * s
    end

    return {qw, qx, qy, qz}
end

local function QuaternionToCFrame(q, pos)
    local qw, qx, qy, qz = unpack(q)
    local xx, xy, xz = qx * qx, qx * qy, qx * qz
    local yy, yz, zz = qy * qy, qy * qz, qz * qz
    local wx, wy, wz = qw * qx, qw * qy, qw * qz

    local cframe = CFrame.new(
        pos.x, pos.y, pos.z,
        1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy),
        2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx),
        2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy)
    )
    
    return cframe
end

local function SlerpCFrame(a, b, t)
    -- Extract positions
    local aPos, bPos = a.Position, b.Position
    -- Interpolate positions linearly
    local interpPos = aPos:Lerp(bPos, t)

    -- Extract quaternions from CFrames
    local aQuat = QuaternionFromCFrame(a)
    local bQuat = QuaternionFromCFrame(b)

    -- Perform slerp on the quaternions
    local dot = aQuat[1] * bQuat[1] + aQuat[2] * bQuat[2] + aQuat[3] * bQuat[3] + aQuat[4] * bQuat[4]

    if dot < 0 then
        bQuat = {-bQuat[1], -bQuat[2], -bQuat[3], -bQuat[4]}
        dot = -dot
    end

    local theta_0 = math.acos(dot)
    local theta = theta_0 * t

    local sin_theta = math.sin(theta)
    local sin_theta_0 = math.sin(theta_0)

    local s1 = math.cos(theta) - dot * sin_theta / sin_theta_0
    local s2 = sin_theta / sin_theta_0

    local finalQuat = {
        s1 * aQuat[1] + s2 * bQuat[1],
        s1 * aQuat[2] + s2 * bQuat[2],
        s1 * aQuat[3] + s2 * bQuat[3],
        s1 * aQuat[4] + s2 * bQuat[4]
    }

    -- Convert the interpolated quaternion back to CFrame
    return QuaternionToCFrame(finalQuat, interpPos)
end

local function calculateSpinStep(_dt: number, inVehicle: boolean)
	local theta = 0

	if inVehicle then
		theta = 0
	elseif spinPart == prevSpinPart then
		local rotation = spinPart.CFrame - spinPart.CFrame.Position
		local prevRotation = prevSpinCFrame - prevSpinCFrame.Position

		local spinAxis = rotation:VectorToObjectSpace(upVector)
		theta = twistAngle(prevRotation:ToObjectSpace(rotation), spinAxis)
	end

	twistCFrame = CFrame.fromEulerAnglesYXZ(0, theta, 0)

	prevSpinPart = spinPart
	prevSpinCFrame = spinPart.CFrame
end

--

return function(PlayerModule)
	------------ Platformer Controls @ocula 
	local ControlModule = require(PlayerModule.ControlModule)
	--[[
		What information do we need for platform controller?

		#ATTRIBUTE SETUP 

		Our platform controller will set the following attributes on the Humanoid:
			

			"JumpsLeft" 	--> Default is 2 
			"DashesLeft" 	--> Default is 1 
			"RollsLeft" 	--> Default is 1

			--> Everytime we land on the ground -

			"Rolling" -->
			"Dashing" -->
			"Jumping" -->
				> 

		#SUPPORTED BEHAVIORS
			> Double Jump (Space / TouchButton)
			> Air Dash (Jump + Roll)
			> Roll (L/R Shift)
			> Long Jump (Roll + Jump) 
			> 

		#CONTROL/STATE SETUP 
		> 1) Jump requests 
		> 2) Dash/Roll requests (dash is a roll in the air)
			> Rolling (we can continue to roll until the player puts in any other input)
				> Roll-mechanic will work like this:
				> Start a roll --> player will essentially just move in a forward line until another input comes in.
				
		> 3) 

	--]]
	------------
	local cameraUtils = require(PlayerModule.CameraModule.CameraUtils)

	function cameraUtils.getAngleBetweenXZVectors(v1: Vector3, v2: Vector3): number
		v1 = upCFrame:VectorToObjectSpace(v1)
		v2 = upCFrame:VectorToObjectSpace(v2)
	
		return math.atan2(
			v2.X*v1.Z - v2.Z*v1.X, 
			v2.X*v1.X + v2.Z*v1.Z
		)
	end

	------------ Spring Util (not using CamUtils one... it's old and doesn't have damping protections) @ocula

	local Position = {
		RightVector = Vector3.new(1,0,0), 
		UpVector = Vector3.new(0,1,0), 
		Position = Vector3.new()
	}

	local Velocity = {
		RightVector = Vector3.new(1,0,0), 
		UpVector = Vector3.new(0,1,0), 
		Position = Vector3.new()
	}

	local Goal = {
		RightVector = Vector3.new(1,0,0), 
		UpVector = Vector3.new(0,1,0), 
		Position = Vector3.new()
	}

	local spring = require(script.Spring) 

	local CameraPositionSpring = spring.new(
		Position, Velocity, Goal 
	)
	
	--CameraPositionSpring.frequency = 32
	--CameraPositionSpring.dampener = 1
	------------
	local poppercam = require(PlayerModule.CameraModule.Poppercam)
	local zoomController = require(PlayerModule.CameraModule.ZoomController)

	function poppercam:Update(renderDt: number, desiredCameraCFrame: CFrame, desiredCameraFocus: CFrame, _cameraController: any)
		local rotatedFocus = desiredCameraFocus * (desiredCameraCFrame - desiredCameraCFrame.Position)
		local extrapolation = self.focusExtrapolator:Step(renderDt, rotatedFocus)
		local zoom = zoomController.Update(renderDt, rotatedFocus, extrapolation)
		return rotatedFocus*CFrame.new(0, 0, zoom), desiredCameraFocus
	end	

	------------
	local baseCamera = require(PlayerModule.CameraModule.BaseCamera)
    local basePitchYaw = Vector2.new(math.pi/2,math.rad(90))


	baseCamera.cache = {} 

    local EPSILON = 1e-6 

	local max_y = math.rad(80)
	local min_y = math.rad(-80)

    local asinLimit = math.asin(1) 

    function baseCamera:Reset()
        self._pitchYaw = basePitchYaw 
    end

    function baseCamera:GetCameraLookVector() 
        if not self._pitchYaw then 
            self._pitchYaw = basePitchYaw 
        end 

        local pitch, yaw = self._pitchYaw.X, self._pitchYaw.Y

		--yaw = math.rad(90) 

        local yTheta, zTheta = math.rad(yaw), math.rad(pitch) 

        local lookVector = CFrame.Angles(0,yTheta,0) * CFrame.Angles(zTheta, 0, 0) * upCFrame.YVector

        return lookVector 
    end

	function baseCamera:GetPitchYaw()
		return self._pitchYaw 
	end 

	function baseCamera:UpdatePitchYaw(rotateInput: Vector2, cameraRelative: bool): Vector2
		-- Update pitch and yaw with input
		local updatedPY = self._pitchYaw + rotateInput or Vector2.new()
	
		-- Clamp yaw between -2π + EPSILON and 2π - EPSILON
		-- Clamp pitch between 0.2 and 180 degrees - EPSILON
		local min = -((math.pi * 2)) + EPSILON
		local max = -min 

		local newPY = Vector2.new(
			math.clamp(updatedPY.X, min, max), 
			math.clamp(updatedPY.Y, math.rad(30), math.rad(160)) --max)
		)

		local lerpFactor = 0.7

		if math.abs(newPY.X) >= max then 
			newPY = Vector2.new(0, newPY.Y)
			lerpFactor = 1 
		end


		--[[local newPY = Vector2.new(
			math.clamp(updatedPY.X, -((math.pi * 2) - EPSILON), ((math.pi * 2) - EPSILON)),
			math.clamp(updatedPY.Y, math.rad(30), math.rad(180) - EPSILON)
		)
	
		-- Prevent pitch and yaw from being too close to zero
		if math.abs(newPY.X) < EPSILON then
			newPY = Vector2.new(newPY.X + EPSILON, newPY.Y)
		end
	
		if math.abs(newPY.Y) < EPSILON then
			newPY = Vector2.new(newPY.X, newPY.Y + EPSILON)
		end
	
		-- Reset yaw if it approaches 2π
		if math.abs(newPY.X) >= math.pi * 2 - EPSILON then
			newPY = Vector2.new(0, newPY.Y)
		end

		warn(newPY)--]]
	
		-- Smoothly interpolate to the new pitch and yaw
		self._pitchYaw = self._pitchYaw:lerp(newPY, lerpFactor) 
	
		return self._pitchYaw
	end
	

	function baseCamera:CalculateNewLookCFrameFromArg(suppliedLookVector: Vector3?, rotateInput: Vector2): CFrame
        local pitchYaw = self:UpdatePitchYaw(rotateInput)

		local currLookVector: Vector3 = suppliedLookVector or self:GetCameraLookVector()

		currLookVector = upCFrame:VectorToObjectSpace(currLookVector)

		local currPitchAngle = math.asin(currLookVector.Y)

        if currPitchAngle ~= currPitchAngle then -- NaN protection
            currPitchAngle = asinLimit * currLookVector.Y 
        end 

		local yTheta = math.clamp(pitchYaw.Y, -max_y + currPitchAngle, -min_y + currPitchAngle)
		local constrainedRotateInput = Vector2.new(pitchYaw.X, yTheta)
		local startCFrame = CFrame.new(Vector3.zero, currLookVector)
		local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.X, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.Y,0,0)

		self.cache.lookCFrame = newLookCFrame 

		return newLookCFrame
	end

	------------
	local vehicleCameraCore = require(PlayerModule.CameraModule.VehicleCamera.VehicleCameraCore)
	local setTransform = vehicleCameraCore.setTransform

	function vehicleCameraCore:setTransform(transform: CFrame)
		transform = upCFrame:ToObjectSpace(transform.Rotation) + transform.Position
		return setTransform(self, transform)
	end

	------------
	local cameraObject = require(PlayerModule.CameraModule)
	local cameraInput = require(PlayerModule.CameraModule.CameraInput)

	function cameraObject:GetUpVector(): Vector3
		return upVector
	end

	function cameraObject:GetCameraInput()
		return cameraInput
	end 

	function cameraObject:GetTargetUpVector(): Vector3
		return targetUpVector
	end

	function cameraObject:SetTargetUpVector(target: Vector3)
		targetUpVector = target
	end

	function cameraObject:GetSpinPart(): BasePart
		return spinPart
	end

	function cameraObject:SetSpinPart(part: BasePart)
		spinPart = part
	end

	function cameraObject:SetTransitionRate(rate: number)
		transitionRate = rate
	end

	function cameraObject:GetTransitionRate(): number
		return transitionRate
	end
	
	function cameraObject:GetCameraCFrame()
		if self.activeCameraController then
			return self._cameraCFrame or CFrame.new() 
		end 
	end 

	function cameraObject:GetCameraLookVector()
		if self.activeCameraController then
			return self.activeCameraController.cache.lookCFrame.LookVector 
		end 
	end 

    function cameraObject:IsFirstPerson()
		if self.activeCameraController then
			return self.activeCameraController.inFirstPerson
		end
		return false
	end
	
	function cameraObject:IsMouseLocked()
		if self.activeCameraController then
			return self.activeCameraController:GetIsMouseLocked()
		end
		return false
	end
	
	function cameraObject:IsToggleMode()
		if self.activeCameraController then
			return self.activeCameraController.isCameraToggle
		end
		return false
	end

	function cameraObject:GetPitchYaw()
		if self.activeCameraController then 
			return self.activeCameraController:GetPitchYaw() 
		end 
	end 
    
	function cameraObject:IsCamRelative()
		return self:IsMouseLocked() or self:IsFirstPerson()
	end

	function cameraObject:Reset()
		targetUpVector = Vector3.new(0,1,0)

		if self.activeCameraController then 
			self.activeCameraController:Reset()
		end 
	end
	
	function cameraObject:Update(dt: number)
		if not self.activeCameraController then
			return
		end
	
		self.activeCameraController:UpdateMouseBehavior()
	
		local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
		local lockOffset = self.activeCameraController:GetIsMouseLocked() 
			and self.activeCameraController:GetMouseLockOffset() 
			or Vector3.new(0, 0, 0)
	
		calculateUpStep(dt)
		calculateSpinStep(dt, self:ShouldUseVehicleCamera())
	
		-- Fix an issue with vehicle cameras
		local fixedCameraFocus = CFrame.new(newCameraFocus.Position)
		local camRotation = upCFrame * twistCFrame * fixedCameraFocus:ToObjectSpace(newCameraCFrame)
		local adjustedLockOffset = -newCameraCFrame:VectorToWorldSpace(lockOffset) + camRotation:VectorToWorldSpace(lockOffset)
	
		newCameraFocus = fixedCameraFocus + adjustedLockOffset
		newCameraCFrame = newCameraFocus * camRotation
	
		-- Adjust the camera CFrame to a higher position
		newCameraCFrame *= CFrame.new(0, 5, 0)

		--
		CameraPositionSpring.goal = {
			RightVector = newCameraCFrame.RightVector, 
			UpVector = newCameraCFrame.UpVector, 
			Position = newCameraCFrame.Position 
		}

		local SpringUpdate = CameraPositionSpring:update(dt)

		newCameraCFrame = newCameraCFrame

		local currentCamera = game.Workspace.CurrentCamera :: Camera

		currentCamera.CFrame = newCameraCFrame
		currentCamera.Focus = newCameraFocus
	
		self._cameraCFrame = newCameraCFrame
	
		-- Fixes issue with follow camera
		self.activeCameraController.lastCameraTransform = newCameraCFrame
		self.activeCameraController.lastCameraFocus = newCameraFocus
	
		-- Update character local transparency as needed based on camera-to-subject distance
		if self.activeTransparencyController then
			self.activeTransparencyController:Update(dt)
		end
	
		-- Reset camera input for the frame end if input is enabled
		if cameraInput.getInputEnabled() then
			cameraInput.resetInputForFrameEnd()
		end
	end
end