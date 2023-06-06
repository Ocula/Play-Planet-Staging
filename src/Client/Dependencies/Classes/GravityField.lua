-- Gravity Field
-- @ocula
-- October 19, 2020

local GravityField = {}
GravityField.__index = GravityField

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Region3 = require(Shared.Region3) 

function GravityField.new(Object) -- The part that is acting as the Gravity Field is tagged with "GravityField"
	-- The object has an (optional) Folder inside that configures the values for the Gravity Field.

	-- Gravity Settings that can be manipulated via attributes:
	--			Radius 			[num]
	--			GrabRadius 		[num]
	--			Priority 		[0,1,2,3]
	--			Type 			["Normal", "GravityField"] 

	-- Gravity Zone Setup:
	--			State [StringVariable]		["Normal", "GravityField"]
	--			->   Field [ObjectValue]	[Points to Object zone is anchoring to] 

	local self = setmetatable({
		Object		= Object; 
		State 		= (Object:FindFirstChild("State") or {Value = "GravityField"}).Value;
		Radius		= (Object.Size.X + Object.Size.Y + Object.Size.Z)/2;
		GrabRadius  = 1.5; 
		Priority 	= 0; 

		Node_Map 	= Object:FindFirstChild("Node_Map"), 
	}, GravityField) 

	local nMap = Object:FindFirstChild("Node_Map")
	
	if nMap then 
		self.Node_Map = nMap.Holder:GetChildren() 
	end 

	local _attributes = Object:GetAttributes()

	for _index, _value in pairs (_attributes) do 
		self[_index] = _value 
	end 

	local function _checkZone()
		local _zones = game:GetService("CollectionService"):GetTagged("GravityZone")

		for i,v in pairs(_zones) do
			if v then 
				local _State = v:FindFirstChild("State") 
				if _State then 
					local _Field = _State:FindFirstChild("Field") 
			
					if _Field then 
						if _Field.Value == Object then
							return v
						end
					end
				end 
			end 
		end 
	end 


	-- Setup Gravity Zone 
	-- Search the Gravity Zone tag for Gravity Zones, and if we find the one for this GravityField, attach it to this Field. 
	local _zone = _checkZone() 

	if not _zone then 
		warn("Zone not found, searching.") 

		local _timeOut = 0 

		repeat
			task.wait(1/30)
			_zone = _checkZone() 

			_timeOut += 1 

			if _timeOut > 100 then 
				warn("No Gravity Zone was set for Gravity Field ... Search Timed Out") 
				break 
			end 
		until _zone ~= nil 
	end 

    self.Zone = Region3.FromPart(_zone)

    task.spawn(function() 
        repeat 
            task.wait(1/30) 
        until _zone:IsDescendantOf(workspace) 

        _zone:Destroy() 
    end)
	
	-- Now finally, set the Ray Direction 
	self.GetRayDirection = function(_origin) 
		return (Object.Position - _origin).Unit
	end 

	warn("New field:", self)

	return self 
end

function GravityField:GetNormalFromCFrame(_cf)
	local org = _cf.p 
	local dir = self.GetRayDirection(_cf.p) * math.huge

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {self.Object}
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

	local _cast = workspace:Raycast(org, dir, raycastParams) 

	if (_cast) then 
		return _cast.Normal 
	end 
end 

function GravityField:IsPlayerInRange(_range) -- < bool, just returns distance from field if true >  We should only check the 3 nearest fields. 
	local Player 	= game.Players.LocalPlayer 
	local HRP		= Player.Character:FindFirstChild("HumanoidRootPart")

	if (HRP == nil) then return end 

	local _currentPosition = HRP.CFrame.p 

	if (_currentPosition ~= _currentPosition) then 
		_currentPosition = self.Object.Position + Vector3.new(0,1,0)
	end 

	if (_range) then 
		local _magnitude = (_currentPosition - self.Object.Position).Magnitude 
		return math.clamp(_magnitude, 1, math.huge)
	end 

	if (self.FieldNet) then 
		return HRP.Position.Y < self.FieldNet.Position.Y 
	end

	if (self.Zone) then -- Check if within Zone Region.
		return self.Zone:CastPoint(_currentPosition), true 
	else 
		-- Check if Field is within reach. 
		return (self.Object.Position - HRP.Position).Magnitude <= self.Radius*(self.GrabRadius or 2)
	end 
end 

function GravityField:Destroy()
	if (self.Object) then 
		if (self.Zone) then 
			self.Zone:Destroy() 
		end 
	end
end

return GravityField