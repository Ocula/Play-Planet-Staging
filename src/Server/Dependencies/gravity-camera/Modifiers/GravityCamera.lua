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
        local updatedPY = self._pitchYaw + rotateInput 

        local newPY = Vector2.new(math.clamp(updatedPY.X, -((math.pi*2) - EPSILON) , 
                    ((math.pi*2) + EPSILON)), math.clamp(updatedPY.Y, 0.2, math.rad(180)-EPSILON))

        if math.abs(newPY.X) < EPSILON then
            newPY = Vector2.new(newPY.X + EPSILON, newPY.Y) 
        end

        if math.abs(newPY.Y) < EPSILON then
            newPY = Vector2.new(newPY.X, newPY.Y + EPSILON) 
        end

        if math.abs(newPY.X) >= math.pi*2 - EPSILON then 
			newPY = Vector2.new(0,newPY.Y)
		end 
		
		if math.abs(newPY.Y) > (max_y * 2) then 
			newPY = Vector2.new(newPY.X,newPY.Y) 
		end

        self._pitchYaw = newPY 

		--test
		--[[if self.inFirstPerson or self:GetIsMouseLocked() then 
			self._pitchYaw = Vector2.new(newPY.X, basePitchYaw.Y)
		end--]]

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
		if self.activeCameraController then
			self.activeCameraController:UpdateMouseBehavior()

			local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
			local lockOffset = self.activeCameraController:GetIsMouseLocked() 
							and self.activeCameraController:GetMouseLockOffset()
							or Vector3.new(0, 0, 0)

			calculateUpStep(dt)
			calculateSpinStep(dt, self:ShouldUseVehicleCamera())

			local fixedCameraFocus = CFrame.new(newCameraFocus.Position) -- fixes an issue with vehicle cameras
			local camRotation = upCFrame * twistCFrame * fixedCameraFocus:ToObjectSpace(newCameraCFrame)
			local adjustedLockOffset = -newCameraCFrame:VectorToWorldSpace(lockOffset) + camRotation:VectorToWorldSpace(lockOffset)
			
			newCameraFocus = fixedCameraFocus + adjustedLockOffset
			newCameraCFrame = newCameraFocus * camRotation
	
			--if self.activeOcclusionModule then
			--	newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
			--end
	
			-- Here is where the new CFrame and Focus are set for this render frame
			local currentCamera = game.Workspace.CurrentCamera :: Camera
			currentCamera.CFrame = newCameraCFrame
			currentCamera.Focus = newCameraFocus

			self._cameraCFrame = newCameraCFrame

			-- fixes issue with follow camera
			self.activeCameraController.lastCameraTransform = newCameraCFrame
			self.activeCameraController.lastCameraFocus = newCameraFocus
	
			-- Update to character local transparency as needed based on camera-to-subject distance
			if self.activeTransparencyController then
				self.activeTransparencyController:Update(dt)
			end
	
			if cameraInput.getInputEnabled() then
				cameraInput.resetInputForFrameEnd()
			end
		end
	end
end