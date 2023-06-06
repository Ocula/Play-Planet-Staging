local transitionRate: number = 0.15

local upCFrame: CFrame = CFrame.new()
local upVector: Vector3 = upCFrame.YVector
local targetUpVector: Vector3 = upVector
local twistCFrame: CFrame = CFrame.new()

local spinPart: BasePart = workspace.Terrain
local prevSpinPart: BasePart = spinPart
local prevSpinCFrame: CFrame = spinPart.CFrame

--

local debugValues = {} 

local function getRotationBetween(u, v, axis)
    local dot = u:Dot(v)
    local uxv = u:Cross(v)

    local tolerance = 0.00001 -- Tolerance threshold for comparing dot product

    if dot < -1 - tolerance then
        return CFrame.fromAxisAngle(axis, math.pi)
    end

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
	local cameraObject = require(PlayerModule.CameraModule)
	local cameraInput = require(PlayerModule.CameraModule.CameraInput)

	local baseCamera = require(PlayerModule.CameraModule.BaseCamera)

	local basePitchYaw = Vector2.new(math.pi/2,math.rad(90))

	local max_y = math.rad(80)	
	local min_y = math.rad(-80)

	local lastCurrPitchAngle = 0 

	local EPSILON = 1e-6	

	function baseCamera:GetDesiredPitchYaw()
		if not self._pitchYaw then 
			self._pitchYaw = basePitchYaw
			self._lastPitchYaw = self._pitchYaw 
		end

		return self._pitchYaw, self._lastPitchYaw
	end 

	function baseCamera:SetDesiredPitchYaw(rotateInput: Vector2)
		if not self._pitchYaw then 
			self._pitchYaw = basePitchYaw
			self._lastPitchYaw = self._pitchYaw 
		end 

		local _lastUpVector = upCFrame.YVector 
		local _nextUpVector = targetUpVector 

		local _calculatedPitch = self._pitchYaw + rotateInput

		_calculatedPitch = Vector2.new(math.clamp(_calculatedPitch.X, -((math.pi*2) - EPSILON) , ((math.pi*2) + EPSILON)), math.clamp(_calculatedPitch.Y, 0.2, math.rad(180)-EPSILON))

		if math.abs(_calculatedPitch.X) < EPSILON then
			_calculatedPitch = Vector2.new(_calculatedPitch.X + EPSILON, _calculatedPitch.Y) 
		end

		if math.abs(_calculatedPitch.Y) < EPSILON then
			_calculatedPitch = Vector2.new(_calculatedPitch.X, _calculatedPitch.Y + EPSILON) 
		end
		
		debugValues.One = "CalculatedPitch: "..tostring(_calculatedPitch)
		-- self:UpdateDebug()  
		-- now clamp our pitch/yaw 
		if math.abs(_calculatedPitch.X) >= math.pi*2 - EPSILON then 
			_calculatedPitch = Vector2.new(0,_calculatedPitch.Y)
		end 
		
		if math.abs(_calculatedPitch.Y) > (max_y * 2) then 
			_calculatedPitch = Vector2.new(_calculatedPitch.X,_calculatedPitch.Y) 
		end

		--math.clamp(pitchYaw.X, -(math.pi*2), math.pi*2), math.clamp(pitchYaw.Y, 0.2, (math.rad(180)-EPSILON))

		self._pitchYaw = _calculatedPitch

		return self._pitchYaw 
	end 

	function baseCamera:SetDesiredLookVector(lV)
		if not self._desiredLookVector then 
			self._desiredLookVector = Vector3.new()
			self._lastDesiredLookVector = Vector3.new() 
		end

		if lV ~= self._desiredLookVector then
			self._lastDesiredLookVector = self._desiredLookVector
			self._desiredLookVector = lV
		end 
		
	end 

	function baseCamera:Reset()
		self._lastPitchYaw = Vector2.new(0,0)
		self._pitchYaw = basePitchYaw
		self._desiredLookVector = Vector3.new(0,1,0) 
		self._lastDesiredLookVector = Vector3.new(0,1,0) 
	end  

	function baseCamera:GetDesiredCameraLookVector(pitchYawBrute: Vector2) 
		-- Scaling the rotate input by the sensitivity factor
		local pitchYaw = pitchYawBrute or self:GetDesiredPitchYaw()

		local pitch, yaw = pitchYaw.X, pitchYaw.Y 

		self._pitchYaw = Vector2.new(pitch, yaw) 

		local yTheta = math.rad(yaw)
		local zTheta = math.rad(pitch)

		local lookVector = CFrame.Angles(0,yTheta,0) * CFrame.Angles(zTheta, 0 , 0) * upCFrame.YVector 

		if lookVector.Y ~= lookVector.Y then 
			lookVector = Vector3.new(0,-1,0) 
		end 

		self:SetDesiredLookVector(lookVector)

		debugValues.Two = "desiredLookVector: "..tostring(lookVector)
	
		return lookVector
	end

	function baseCamera:CalculateNewLookCFrameFromArg(suppliedLookVector: Vector3?, rotateInput: Vector2): CFrame
		-- Set desiredPitchYaw
		local _currentPitchYaw = self:SetDesiredPitchYaw(rotateInput)
		
		-- Calculate desiredLookVector first
		local currLookVector: Vector3 = suppliedLookVector or self:GetDesiredCameraLookVector()

		currLookVector = upCFrame:VectorToObjectSpace(currLookVector)

		local currPitchAngle = math.asin(currLookVector.Y)

		if currPitchAngle ~= currPitchAngle then 
			currPitchAngle = lastCurrPitchAngle 
		else 
			lastCurrPitchAngle = currPitchAngle 
		end 

		local yTheta = math.clamp(_currentPitchYaw.Y, -max_y + currPitchAngle, -min_y + currPitchAngle)
		local constrainedRotateInput = Vector2.new(_currentPitchYaw.X, yTheta)
		
		local startCFrame = CFrame.new(Vector3.zero, currLookVector)

		local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.X, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.Y,0,0)

		debugValues.Three = "currLookVector: "..tostring(currLookVector) 
		debugValues.Four = "lookVectorY: "..tostring(currLookVector.Y) 
		debugValues.Five = "currPitchAngle: "..tostring(currPitchAngle)

		return newLookCFrame--]]
	end

	------------
	local vehicleCameraCore = require(PlayerModule.CameraModule.VehicleCamera.VehicleCameraCore)
	local setTransform = vehicleCameraCore.setTransform

	function vehicleCameraCore:setTransform(transform: CFrame)
		transform = upCFrame:ToObjectSpace(transform.Rotation) + transform.Position
		return setTransform(self, transform)
	end

	------------
	--local cameraObject = require(PlayerModule.CameraModule)
	--local cameraInput = require(PlayerModule.CameraModule.CameraInput)

	function cameraObject:GetUpVector(): Vector3
		return upVector
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
	
	function cameraObject:IsCamRelative()
		return self:IsMouseLocked() or self:IsFirstPerson()
		--return self:IsToggleMode(), self:IsMouseLocked(), self:IsFirstPerson()
	end

	function cameraObject:GetTransitionRate(): number
		return transitionRate
	end

	function cameraObject:Reset()
		targetUpVector = Vector3.new(0,1,0)

		if self.activeCameraController then 
			self.activeCameraController:Reset()
		end 
	end 

	function cameraObject:UpdateDebug()
        local player = game.Players.LocalPlayer
        local pGUI = player:WaitForChild("PlayerGui")
        local debugUI = pGUI:WaitForChild("Debug") 

        for name, text in pairs(debugValues) do 
            if debugUI:FindFirstChild("Frame") then 
                if type(text) == "string" then 
                    debugUI.Frame[name].Text = text
                else 
                    debugUI.Frame[name].Visible = text 
                end 
            end 
        end 
    end 

	-- jitter debug
	local orientation = Vector3.zero
	local averageMagnitude = 0 

	local marginOfError = {MAX = 1, MIN = 1}

	function cameraObject:Update(dt: number)
		if self.activeCameraController then
			self.activeCameraController:UpdateMouseBehavior()

			--local _lastCameraCFrame = workspace.CurrentCamera.CFrame -- use this only for pushing out ÷ by 0 errors. 
			local lastPitchYaw = self.activeCameraController._lastPitchYaw

			local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
			local lockOffset = self.activeCameraController:GetIsMouseLocked() 
							and self.activeCameraController:GetMouseLockOffset()
							or Vector3.new(0, 0, 0)

			debugValues.Six = "oldCFrame: "..tostring(newCameraCFrame)
			debugValues.Eight = "oldFocus: "..tostring(newCameraFocus)  

			--debugValues.One = "oldCFrame: "..tostring(newCameraCFrame)

			calculateUpStep(dt) 
			calculateSpinStep(dt, self:ShouldUseVehicleCamera())

			local fixedCameraFocus = CFrame.new(newCameraFocus.Position) -- fixes an issue with vehicle cameras



			local camRotation = upCFrame * twistCFrame * fixedCameraFocus:ToObjectSpace(newCameraCFrame)

			debugValues.Ten = "camRotation: "..tostring(camRotation)
			debugValues.Eleven = "twistCFrame: "..tostring(twistCFrame)
			debugValues.Twelve = "upCFrame: "..tostring(upCFrame)

			local adjustedLockOffset = -newCameraCFrame:VectorToWorldSpace(lockOffset) + camRotation:VectorToWorldSpace(lockOffset)

			newCameraFocus = fixedCameraFocus + adjustedLockOffset
			newCameraCFrame = newCameraFocus * camRotation
	
			if self.activeOcclusionModule then -- its not bc of occlusion. it's something to do with the lookvector of the camera. 
				newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
			end
	
			-- Here is where the new CFrame and Focus are set for this render frame
			local currentCamera = game.Workspace.CurrentCamera :: Camera

			local LastLookVector = self.activeCameraController.lastLookVector or Vector3.new() 

			currentCamera.CFrame = newCameraCFrame
			currentCamera.Focus = newCameraFocus

			-- Specific use case for stopping random jitters:

			local x,y,z = currentCamera.CFrame:ToOrientation()
			local currentOrientation = Vector3.new(x,y,z)

			local difference = orientation - currentOrientation 
			local magnitude = difference.Magnitude 

			-- 

			orientation = currentOrientation
			averageMagnitude += magnitude 
			averageMagnitude /= 2 

			-- fixes issue with follow camera
			self.activeCameraController.lastCameraTransform = newCameraCFrame
			self.activeCameraController.lastCameraFocus = newCameraFocus
			--self.activeCameraController.lastLookVector = currentLookVector 

			debugValues.Seven = "newCFrame: "..tostring(newCameraCFrame)
			debugValues.Nine = "newFocus: "..tostring(newCameraFocus)
			--debugValues.Thirteen = "cameraLookVector: "..tostring(currentLookVector) 
	
			-- Update to character local transparency as needed based on camera-to-subject distance
			if self.activeTransparencyController then
				self.activeTransparencyController:Update(dt)
			end
	
			if cameraInput.getInputEnabled() then
				cameraInput.resetInputForFrameEnd()
			end--]]


			--
            --[[debugValues.Three = "UpCFrame: "..tostring(upCFrame)
			debugValues.Four = "camRotation: "..tostring(camRotation) 
            debugValues.Five = "newCameraFocus: "..tostring(newCameraFocus)
            debugValues.Six = "newCameraCF: "..tostring(newCameraCFrame--]]
            --debugValues.Seven = "newCameraFocus: "..tostring(newCameraFocus)
            --debugValues.Nine = "fixedCameraFocus: "..tostring(fixedCameraFocus) 
            --debugValues.Eight = "TargetUpVector: "..tostring(targetUpVector) 
    
            self:UpdateDebug() 
		end
	end
end