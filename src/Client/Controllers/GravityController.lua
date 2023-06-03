-- @EmilyBendsSpace – Normal improvements/touchups 
-- @EgoMoose – Gravity Controller basics
-- https://devforum.roblox.com/t/example-source-smooth-wall-walking-gravity-controller-from-club-raven/440229?u=egomoose


-- @ocula – Gravity Field System (2020)

--[[
	Gravity Field System
	
	In theory, the system below will work as such:
		1. Any Gravity Field will anchor the player to that field.
		2. If the player were to get flung/fall endlessly somehow, that gravity field would (should)
		pull them back down to the ground regardless of how they end up.
		3. This means that any objects/meshes are capable of being interpreted into Gravity Fields.
		4. The system will return the normal first of the object itself. 
			-- This is in GravityField.FindNormal(Origin)
			-- This can be changed per Gravity Field as needs see fit. 
			-- For now it only raycasts to the center of the field.
			-- Donut shaped fields will have to calculate a new center. 
		5. Change the "Normal_Limit" to differ slope degrees. 

	To add a Gravity Field – 
		1. Any object/field you wish to be considered a Gravity Field must have a 
		tag, "GravityField" on it. Optionally, you can have a folder inside titled
		"GF_Settings" with configurable settings on the field itself.

		2. If this object is within the workspace on any time local fields are loaded in,
		it will be accounted for.

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Utility = require(Shared:WaitForChild("Utility")) 

local Signal = require(Shared:WaitForChild("Signal"))
local Binder = require(Shared:WaitForChild("Binder")) 

local GravityClass = require(Knit.Modules.Classes.GravityClass)

local GravityController = Knit.CreateController { 
    Name = "GravityController",
    State = "Normal",
    Field = nil;
	Controller = nil;
	
	FieldChangedDebounce = os.clock();
	JumpRequest = false;
	ProcessJump = false;
	Platforming = false;
	HeartbeatConnection = nil; 
	Active = false; 

	ActiveFields = {};

	Field_Type = "Center",
	Field_Net_Active = false;

	GravityFieldTimeout = os.time(); 
	DebounceWait = 0.05
}

-- Private Methods

function GravityController:_checkNormals(a, b)
	local angle = (math.acos(a:Dot(b)/(a.Magnitude * b.Magnitude))) --* sn
	return math.deg(angle) 
end

function GravityController:_getNearestField()
	if (Utility:CountTable(self.ActiveFields) == 0) then warn("No active fields found.") return end 

	local _closestField, _maxDistance = nil, math.huge 

	for _, currentFieldCheck in pairs(self.ActiveFields) do
		if (currentFieldCheck) then
			--[[local _hit = false 

			if (GameController.State ~= "Lobby" and currentFieldCheck.LobbyFriendly) then 
				warn("Lobby zone hit... continuing")
				_hit = true 
				continue 
			end 

			if (_hit) then print("Hit") end --]]
			
			local _distanceCheck = currentFieldCheck:IsPlayerInRange(true)

			if (_distanceCheck < _maxDistance) then 
				_maxDistance = _distanceCheck
				_closestField = currentFieldCheck 
			end
		end
	end

	return _closestField 
end 

-- @ Proxy for self.ActiveFields[Object] 
function GravityController:_findField(Object)
	return self.ActiveFields[Object]
end

function GravityController:_getFieldFromNode(_node)
	local _fieldObj = _node.Parent.Parent.Parent 
	return self.ActiveFields[_fieldObj] 
end 

function GravityController:_getFieldObjectFromNode(_node)
	local _fieldObj = _node.Parent.Parent.Parent 
	return _fieldObj 
end 

function GravityController:_getFieldWithHighestPriority()
	local _priorityCheck = math.huge 
	local _fieldFound    = nil 

	for i,_field in pairs(self.ActiveFields) do 
		if (_field.Priority < _priorityCheck) then 
			_priorityCheck 	= _field.Priority 
			_fieldFound 	= _field 
		end 
	end

	return _fieldFound 
end 

-- Yields the current thread until the expected field loads. 
function GravityController:WaitForField(object)
	local _field = self.ActiveFields[object] 

	if (not _field) then 
		repeat wait() _field = self.ActiveFields[object] until _field 
	end

	return _field 
end 

-- Public Methods 

function GravityController:SetState(State, _field, _spawn)
	-- First handle this condition: 
	-- If state is the same, but we're trying to set a field. 
	-- This is more important when we're using a server setstate and it is trying to set a field on all players, if some are different, this will remedy that problem. 
	
	if (self.State == State) then 
		local _fieldClass = _field 

		if (type(_field) == "userdata") then 
			_fieldClass = self:_findField(_field) 
		end 

		if (self.Field ~= _fieldClass) then 
			self.Field = _fieldClass 
		end 

		return 
	end 

	-- Now, the State is different. 
	-- Change from previous state to new state. 

	self.State = State
	
	if (State == "GravityField") then -- Our old State must have been "Normal"
		if (not self.Controller) then
			if (_field) then 
				local _fieldClass = _field 

				if (type(_field) == "userdata") then 
					_fieldClass = self:_findField(_field)
				end 

				self.Field = _fieldClass 

				warn("Field set to:", _fieldClass)
			end

			-- 

            local Player = game.Players.LocalPlayer 

			self.Controller = GravityClass.new(Player)
			self.Controller.GetGravityUp = self.GetGravityUp

			-- No field, grab nearest default field. 

			if (not self.Field) then 
				self.Field = self:_getFieldWithHighestPriority() 
			end
		end

		--self:SetActive(true) 
	elseif (State == "Normal") then -- Our old State must have been "GravityField" 
		if (self.Controller) then
			--self.Controller.Camera.normalizeRestraint = true 
			self.Controller:ResetGravity(Vector3.new(0,1,0)) 
			self.Controller:Destroy()

			self.Controller = nil 
			--warn("Controller paused.") 
		end
		
		self.Field = nil 
		
		--self:SetActive(false) 
	elseif (State == "Fly") then 
		-- Now move to GravityField 
		self:SetState("GravityField") 
	end 
end

function GravityController:Raycast(FilterType, Descendants, Origin, Direction)
	local raycastParam = RaycastParams.new()
	raycastParam.FilterType = FilterType
	raycastParam.FilterDescendantsInstances = Descendants 

	return workspace:Raycast(Origin, Direction, raycastParam) 
end 

function GravityController.GetGravityUp(self, oldGravityUp)
	local hrpCF = self.HRP.CFrame
	local Field = GravityController.Field

	if Field then
		local _direction = Field.GetRayDirection(hrpCF.p) * 10000
		local _hrpP      = hrpCF.p 
		local _hitList   = Field.HitList or {}

		table.insert(_hitList, Field.Object)

		local _normalRay = GravityController:Raycast(Enum.RaycastFilterType.Whitelist, _hitList, _hrpP, _direction) 
		
		if _normalRay then
			return _normalRay.Normal 
		else 
			return oldGravityUp
		end
	else
		return oldGravityUp
	end
end--]]

--[[ @ FIELD CHECK 

	Field Check is for searching for any nearby GravityFields or GravityZones:
	If we have an Active Field in self.Field, we should only continue with a check if there's another field in the vicinity.

]]

function GravityController:FieldCheck()
    local Player = game.Players.LocalPlayer

    if not Player.Character then return end 

	local _humRoot = Player.Character:FindFirstChild("HumanoidRootPart") 

	if _humRoot then -- Only continue if our character exists. 
		if self.State == "GravityField" then -- First check our State, if we need a GravityField, then we check the nearest field
			local _nearestField = self:_getNearestField() -- Each GravityField can have a GravityZone 

			if self.Field and not _nearestField then 
				_nearestField = self.Field 
			end

			if not self.Field then -- No active field. So we need to set it to this nearest field.
				self.Field = _nearestField 
				--warn("Field set:", GravityController.Field)
			else
				if _nearestField ~= self.Field.Zone then 
					--warn("Nearest Field:", _nearestField)
					local _fieldInRange, _isZone = _nearestField:IsPlayerInRange() 

					if (_fieldInRange and _isZone) or (_fieldInRange and not _isZone) then 
						--warn("Field is found in range, and it's a zone.") 
					
						self.Field = _nearestField
					elseif not _fieldInRange and _isZone then 
						self.Field =  self:_getFieldWithHighestPriority() -- Fallen out of the zone
					end 
				end 
			end 
		end
	end
end

function GravityController:KnitStart()

	--[[
	self.Services.GravityService.SetState:Connect(function(State, ...)
		self:SetState(State, ...)
	end)--]]

	---------
    local GravityField = require(Knit.Modules.Classes.GravityField)
	local GravityFieldBinder = Binder.new("GravityField", GravityField) 

	GravityFieldBinder:GetClassAddedSignal():Connect(function(_field)
		if _field and not _field._ShellClass then 
			--warn("New Gravity Field:", _field)
			if self.ActiveFields[_field.Object] then warn("GravityField class already created for this field.", _field.Object:GetFullName()) return end 
			self.ActiveFields[_field.Object] = _field 
        end 
	end)

	GravityFieldBinder:GetClassRemovingSignal():Connect(function(_field)
		if self.ActiveFields[_field.Object] then 
			self.ActiveFields[_field.Object] = nil 
		end 
	end) 

	GravityFieldBinder:Start() 

    self:SetState("GravityField")
end

function GravityController:KnitInit()
	-- Set Gravity Modifier on Camera
	--local GravityCamera = require(Shared:FindFirstChild("gravity-camera")) 

    local GravityReset = Signal.new()

    GravityReset:Connect(function()
        local Player = game.Players.LocalPlayer
		-- Connect necessary player events
		Player.CharacterRemoving:Connect(function()
			if (self.State == "GravityField") then 
			--	self:SetState("Normal") 
			end 
		end)
	end)

    table.insert(Knit.Bootup, GravityReset) -- Adds to the Bootup thruline
end

return GravityController