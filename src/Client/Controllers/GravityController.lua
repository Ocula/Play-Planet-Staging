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
local Maid = require(Shared:WaitForChild("Maid"))

local ControllerModule = require(Knit.Modules.Classes.GravityClass)

local GravityController = Knit.CreateController { 
    Name = "GravityController",

    State = "Normal",
    Field = nil,
	Controller = nil,

	_controllerMaid = Maid.new(),
	_lastUpVector = Vector3.new(0,-1,0),
}

-- Private Methods

function GravityController:SetCamera()
	local playerModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
	self.Camera = playerModule:GetCameras() 
end 

function GravityController:GetCamera()
	return self.Camera 
end 

-- @ Proxy for self.ActiveFields[Object] 
function GravityController:GetField(Object)
	return self.ActiveFields[Object]
end

-- Public Methods 
function GravityController:SetState(State) 
	if State == "GravityField" then 
		if not self.Controller then 
			local Player = game.Players.LocalPlayer 

			self.Controller = ControllerModule.new(Player)
			self.Controller.GetGravityUp = self.GetGravityUp

			self._controllerMaid:GiveTask(self.Controller) 
		end 
	else 
		self._controllerMaid:DoCleaning()
	end
end

function GravityController.GetGravityUp(self)
	local Field = GravityController.Field
	assert(Field, "No Field has been set.")

	local GravityService = Knit.GetService("GravityService") 
	local Camera = GravityController:GetCamera() 

	if Field.UpVector then
		local desiredUpVector = Field.UpVector * Field.UpVectorMultiplier
		Camera:SetTargetUpVector(desiredUpVector) 
		return desiredUpVector
	end

	local _setUpVector = self._lastUpVector
	
	GravityService:RequestUpVector(Field.GUID):andThen(function(upVector)
		if upVector then 
			_setUpVector = upVector
			self._lastUpVector = upVector
		end 
	end)

	if _setUpVector then 
		Camera:SetTargetUpVector(_setUpVector) 
	end 

	return _setUpVector 
	--[[if _setUpVector == Vector3.new(0,-1,0) then 
		--print("We're in Normal planar space.")
	end--]]
end--]]

--[[
function GravityController:FieldCheck()
    local Player = game.Players.LocalPlayer

    if not Player.Character then return end 

	local _humRoot = Player.Character:FindFirstChild("HumanoidRootPart") 

	if _humRoot then -- Only continue if our character exists. 
		if self.State == "GravityField" then -- First check our State, if we need a GravityField, then we check the nearest field
			local _nearestField = self:_getNearestField() -- Get nearest field. 

			if self.Field and not _nearestField then 
				_nearestField = self.Field 
			end

			if not self.Field then -- No active field. So we need to set it to this nearest field.
				self.Field = _nearestField 
				warn("Field set:", GravityController.Field)
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
end--]]

function GravityController:KnitStart()
	local GravityService = Knit.GetService("GravityService") 

	GravityService.SetState:Connect(function(State, ...)
		self:SetState(State, ...)
	end)

	GravityService.SetField:Connect(function(Field)
		self.Field = Field
	end) 

	GravityService.ReconcileField:Connect(function(newField)
		if self.Field and newField.GUID == self.Field.GUID then 
			for i,v in pairs(newField) do
				self.Field[i] = v 
			end
		end 
	end) 

	---------
    local GravityField = require(Knit.Modules.Classes.GravityField)
	local GravityFieldBinder = Binder.new("GravityZone", GravityField) 

	self:SetCamera() 

	GravityFieldBinder:Start() 
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

		Player.CharacterAdded:Connect(function()
			if (self.State ~= "Normal") then 
				self:SetState(self.State) 
			end 
		end)
	end)

    table.insert(Knit.Bootup, GravityReset) -- Adds to the Bootup thruline
end

return GravityController