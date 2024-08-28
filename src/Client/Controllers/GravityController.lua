-- @EmilyBendsSpace – Normal improvements/touchups 
-- @EgoMoose – Gravity Controller basics
-- https://devforum.roblox.com/t/example-source-smooth-wall-walking-gravity-controller-from-club-raven/440229?u=egomoose


-- @ocula – Gravity Field System (2023)

--[[

	Client Gravity Controller - Handles interpretation of Server data.

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
	Fields = {},
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
		if not self.Controller and not self._creatingController then
			local Player = game.Players.LocalPlayer 

			self._creatingController = true 
			self.Controller = ControllerModule.new(Player)
			self.Controller.GetGravityUp = function()
				return self:GetGravityUp()
			end 

			self._controllerMaid:GiveTask(self.Controller) 

			self._creatingController = nil 

			self:SetCamera()

			warn("CREATED CONTROLLER!") 
		end 
	else 
		self._controllerMaid:DoCleaning()
		self.Controller = nil
	end
end

function GravityController:GetNormalAtPosition(Position: Vector3)
	local Field = self.Field

	assert(Field, "No field has been set!") 

	local FieldClass = self.Fields[Field]

	return FieldClass:GetNormal(Position)
end 

function GravityController:GetGravityUp()
	local Field = self.Field
	
	assert(Field, "No Field has been set.")

	local Camera = self:GetCamera() 

	local FieldClass = self.Fields[Field] 

	if FieldClass.UpVector then
		local desiredUpVector = FieldClass.UpVector * FieldClass.UpVectorMultiplier

		Camera:SetTargetUpVector(desiredUpVector) 

		return desiredUpVector
	else
		local getGravityUp = FieldClass:GetUpVector(self.Controller:GetPosition())
		--local setUpVector = FieldClass:GetNormal(self.Controller:GetPosition())

		Camera:SetTargetUpVector(getGravityUp)

		return getGravityUp 
	end
end


function GravityController:KnitStart()
	local GravityService = Knit.GetService("GravityService") 

	GravityService.SetState:Connect(function(State, ...)
		warn("Attempted setstate:", State)
		self:SetState(State, ...)
	end)

	GravityService.SetField:Connect(function(Field)
		self.Field = Field.GUID 

		if not self.Fields[Field.GUID] then 
			local GravityField = require(Knit.Modules.Classes.GravityField).new(Field) 

			self.Fields[Field.GUID] = GravityField 

			warn("Created field:", GravityField) 
		end 

		if Field.State ~= self.State then 
			self:SetState(Field.State) 
		end 
	end) 

	GravityService.ReconcileField:Connect(function(newField)
		if self.Field and newField.GUID == self.Field.GUID then 
			for i,v in pairs(newField) do
				self.Field[i] = v 
			end
		end 
	end) 

	---------

	--GravityFieldBinder:Start() --]]
end

function GravityController:KnitInit()
	-- Set Gravity Modifier on Camera

	--local GravityCamera = require(Shared:FindFirstChild("gravity-camera")) 
	--local GravityReset = Signal.new()

    --[[GravityReset:Connect(function()
        local Player = game.Players.LocalPlayer
		-- Connect necessary player events
		Player.CharacterAdded:Connect(function()
			if (self.State ~= "Normal") then 
				warn("setting state on grav controller")
				self:SetState(self.State) 
			end 
		end)
	end)--]]

    --table.insert(Knit.Bootup, GravityReset) -- Adds to the Bootup system 
end

return GravityController