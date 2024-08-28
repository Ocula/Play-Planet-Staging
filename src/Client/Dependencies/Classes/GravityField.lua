-- Gravity Field
-- @ocula
-- June 7, 2023

local GravityField = {}
GravityField.__index = GravityField

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Maid = require(Shared.Maid) 

function GravityField.new(Data) 
	local self = setmetatable({
		Object = Data.Object, 
		_maid = Maid.new() 
	}, GravityField) 

	for key, value in Data do 
		self[key] = value 
	end 

	if not self.Object:FindFirstAncestorOfClass("Workspace") then 
		self._ShellClass = true 
	else 
		self.Object.Transparency = 1 -- Removes the Object on the client. 
		self.Object.CanQuery = false 
		--self._maid:GiveTask(Object) / Game should handle cleaning this up. 
	end

	return self 
end

function GravityField:GetUpVector(pos: Vector3) -- We can use this function to get more detailed UpVectors
    -- This can also be used for NPCs.
    if self.UpVector then -- Block Zone (typically going to point the players into one direction regardless) 
        return self.UpVector * self.UpVectorMultiplier
    else -- Radial Zone (typically pulling the player towards the center of a sphere) 
        local center = self.Center.p 
        local upVector = (pos - center).Unit 

        return upVector * self.UpVectorMultiplier
    end 
end 

function GravityField:GetNormal(Position: Vector3) 
    local Shapecast = require(Knit.Library.Shapecast) 
    local UpVector = self:GetUpVector(Position) 

	local Cast = Shapecast.cast("Sphere", Position, Vector3.new(2,2,2), -UpVector * 3.5, {game.Players.LocalPlayer.Character})

	if Cast then
		if self.Debug then 
			self.Debug.Position = Cast.Position
		else 
			self.Debug = Instance.new("Part") 
			self.Debug.Shape = Enum.PartType.Ball 
			self.Debug.Transparency = 0.8
			self.Debug.Color = Color3.new(1,0,0)
			self.Debug.Size = Vector3.new(2,2,2) 
			self.Debug.CanCollide = false 
			self.Debug.Anchored = true 

			self.Debug.Parent = game.Players.LocalPlayer.Character 
			self.Debug.Position = Cast.Position 
		end 

		return Cast.Normal, Cast
	else 
		return UpVector
	end 
end 

function GravityField:Destroy()
	self._maid:DoCleaning() 
end

return GravityField