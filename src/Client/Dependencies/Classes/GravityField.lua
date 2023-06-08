-- Gravity Field
-- @ocula
-- June 7, 2023

local GravityField = {}
GravityField.__index = GravityField

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Maid = require(Shared.Maid) 

function GravityField.new(Object)
	local self = setmetatable({
		_maid = Maid.new() 
	}, GravityField) 

	if not Object:FindFirstAncestorOfClass("Workspace") then 
		self._ShellClass = true 
	else 
		Object.Transparency = 1 -- Removes the Object on the client. 
		Object.CanQuery = false 

		--self._maid:GiveTask(Object) / Game should handle cleaning this up. 
	end

	return self 
end

function GravityField:Destroy()
	self._maid:DoCleaning() 
end

return GravityField