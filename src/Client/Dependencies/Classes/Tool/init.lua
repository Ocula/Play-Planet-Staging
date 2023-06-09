-- Tool
-- @ocula
-- January 2, 2022

--[[

	

]]

local Tool = {
	_tools = {}; 
}

Tool.__index = Tool

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared") 

local Signal = require(Shared:WaitForChild("Signal"))
-- Tool:Equip() can proxy to act on Class
-- We just want a blanket class constructor for tools so that we can use the same methods on all of them..
-- Hotkeys: < {Equip = {Enums}; Engage = {Enums}} > -- Hotkeys can include all forms of input for the same tool. 
-- Note that Hotkeys will likely only be needed on Keyboard devices.
function Tool.new(_toolId, _hotkeys)
	if (not _toolId) then warn("No Tool ID provided. Cannot create Tool.") return {_ShellClass = true} end 

	local _toolIndex = Tool._tools[_toolId] 

	local _toolclass = _toolIndex.new(_hotkeys)

	local self  = setmetatable({
		_tool 	= _toolclass; 
	}, Tool)

	-- Create signals

	self.Equipped 		= Signal.new()
	self.Unequipped 	= Signal.new()
	self._input  		= Signal.new()

	return self
end

-- All of these parent functions should be used because it properly fires these events. 

function Tool:Equip(...)
	self._tool:Equip(...) 
	--
	self.Equipped:Fire(...) 
end 

function Tool:Unequip(...)
	self._tool:Unequip(...)
	--
	self.Unequipped:Fire() 
end 

-- Process all Input 
function Tool:ProcessInput(...)
	self._tool:ProcessInput(...)  
	--
	self._input:Fire(...) 
end 

function Tool:Init()
	for _, module in ipairs(script:GetChildren()) do 
		if (module:IsA("ModuleScript")) then
			local _mod = require(module) 
			self._tools[module.Name] = _mod 
		end 
	end 
end 


return Tool