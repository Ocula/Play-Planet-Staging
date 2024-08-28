--[[
	
--[[
	--local camCF = workspace.CurrentCamera.CFrame
	local camCF = self._camera.CameraModule:GetCameraCFrame() -- We'll manually acquire this to avoid any discrepancies.
	
	-- update the gravity vector
	local oldGravity = self._gravityUp
	local newGravity = self:GetGravityUp(oldGravity)

	if not oldGravity or not newGravity then return end -- packet loss

	local sphericalArc = getRotationBetween(oldGravity, newGravity, camCF.XVector)
	local lerpedArc = sphericalArc--CFrame.new():Lerp(sphericalArc, TRANSITION)

	self._gravityUp = lerpedArc * oldGravity

	-- get world move vector
	local fDot = camCF.ZVector:Dot(newGravity)

	local cForward = math.abs(fDot) > 0.5 and math.sign(fDot) * camCF.YVector or -camCF.ZVector

	local left = -cForward:Cross(newGravity).Unit
	local forward = -left:Cross(newGravity).Unit

	local move = self._control:GetMoveVector()

	local worldMove = (forward * move.z) - (left * move.x)
	  
	local isInputMoving = false
	local length = worldMove.Magnitude

	if length > 0 then
		isInputMoving = true
		worldMove = worldMove / length
	end

	--print(fDot, cForward) 

	-- get the desired character cframe
	local hrpLook = self.HRP.CFrame.LookVector
	local charForward = hrpLook:Dot(forward) * forward + hrpLook:Dot(left)*left

	if self._camera.CameraModule:IsCamRelative() then 
		local lookVector = camCF.LookVector
		-- Project the look vector onto the plane orthogonal to the up vector
		local projectedLookVector = (lookVector - lookVector:Dot(newGravity) * newGravity).Unit
		
		-- Recalculate the look vector to ensure orthogonality
		charForward = projectedLookVector:Dot(forward) * forward + projectedLookVector:Dot(left) * left 
	end 

	local charRight = charForward:Cross(newGravity).Unit

	local newCharCF = CFrame.fromMatrix(ZERO3, charRight, newGravity, -charForward)
	local newCharRotation = CFrame.new()

	if not self._camera.CameraModule:IsCamRelative() then 
		newCharRotation = getRotationBetween(
			charForward,
			worldMove,
			newGravity
		)
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

	--warn("WALKFORCE:", walkForce)

	local charRotation = newCharRotation * newCharCF


	self.StateTracker:Update(self._gravityUp, self._collider:IsGrounded(false), isInputMoving)
	self._collider:Update(walkForce + gForce, charRotation)

	updateDebugVector(charRight, newGravity, -charForward)--charRotation.XVector, charRotation.YVector, charRotation.LookVector)

	
local function onGravityStep(self, dt)
    -- Acquire the camera's current CFrame
    local camCF = workspace.CurrentCamera.CFrame

    -- Update the gravity vector
    local oldGravity = self._gravityUp
    local newGravity = self:GetGravityUp(oldGravity)

    if not oldGravity or not newGravity then return end -- packet loss

    -- Smooth transition between gravity vectors
    local sphericalArc = getRotationBetween(oldGravity, newGravity, camCF.XVector)
    local lerpedArc = CFrame.new():Lerp(sphericalArc, TRANSITION)

    -- Update gravity vector smoothly
    self._gravityUp = (lerpedArc * oldGravity).Unit

    -- Calculate tangential look vector
    local camLookVector = camCF.LookVector
    local tangentialLookVector = camLookVector - (camLookVector:Dot(self._gravityUp) * self._gravityUp)
    if tangentialLookVector.Magnitude > 0 then
        tangentialLookVector = tangentialLookVector.Unit
    else
        tangentialLookVector = Vector3.new(0, 0, -1) -- Default direction if zero magnitude
    end

    -- Get the camera's right vector relative to the new gravity
    local camRight = tangentialLookVector:Cross(self._gravityUp)
    if camRight.Magnitude > 0 then
        camRight = camRight.Unit
    else
        camRight = Vector3.new(1, 0, 0) -- Default direction if zero magnitude
    end

    -- Get the move vector from the controls
    local move = self._control:GetMoveVector()
    local worldMove = (tangentialLookVector * move.z) - (camRight * move.x)
    local isInputMoving = worldMove.Magnitude > 0

    if isInputMoving then
        worldMove = worldMove.Unit
    end

    -- Calculate the new character rotation
    local charRight = worldMove:Cross(self._gravityUp)
    if charRight.Magnitude > 0 then
        charRight = charRight.Unit
    else
        charRight = Vector3.new(1, 0, 0) -- Default direction if zero magnitude
    end
    local charForward = charRight:Cross(self._gravityUp).Unit

    local newCharCF = CFrame.fromMatrix(ZERO3, charRight, self._gravityUp, -charForward)
    local newCharRotation = CFrame.new():Lerp(getRotationBetween(charForward, worldMove, self._gravityUp), 0.7)

    -- First-person specific adjustments
    if self._camera.CameraModule:IsFirstPerson() then
        local newForward = tangentialLookVector
        local newRight = newForward:Cross(self._gravityUp).Unit
        newCharCF = CFrame.fromMatrix(ZERO3, newRight, self._gravityUp, -newForward)
    end

    -- Ensure grounded detection and manage horizontal velocity to prevent slipping
    local grounded = self._collider:IsGrounded(true)
    local cVelocity = self.HRP.Velocity
    local gVelocity = cVelocity:Dot(self._gravityUp) * self._gravityUp
    local hVelocity = cVelocity - gVelocity

    if hVelocity:Dot(hVelocity) < 1 then
        hVelocity = ZERO3
    end

    -- Calculate forces
    local g = workspace.Gravity
    local gForce = g * self._characterMass * (UNIT_Y - self._gravityUp)
    local tVelocity = self.Humanoid.WalkSpeed * worldMove

    local dVelocity = tVelocity - hVelocity
    local dVelocityM = dVelocity.Magnitude

    local walkForceM = math.min(10000, WALK_FORCE * self._characterMass * dVelocityM / (dt * 60))
    local walkForce = walkForceM > 0 and (dVelocity / dVelocityM) * walkForceM or ZERO3

    -- Apply forces only when grounded to prevent slipping
    local totalForce = walkForce + (grounded and gForce or ZERO3)

    -- Apply rotation and forces
    local charRotation = newCharRotation * newCharCF

    self.StateTracker:Update(self._gravityUp, grounded, isInputMoving)
    self._collider:Update(totalForce, charRotation)
end--]]