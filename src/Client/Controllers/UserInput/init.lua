-- User Input
-- Stephen Leitnick / @Ocula (2022) 
-- January 2, 2018 / January 5, 2022

--[[

	This module can be multifaceted in a better sense – certain inputs should be able to work for each game input. 

]]

--[[
	
	UserInput simply encapsulates all user input modules.
	
	UserInput.Preferred
		- Keyboard
		- Mouse
		- Gamepad
		- Touch
	
	UserInput:Get(inputModuleName)
	UserInput:GetPreferred()

	UserInput.PreferredChanged(preferred)
	
	
	Example:
	
	local keyboard = userInput:Get("Keyboard")
	keyboard.KeyDown:Connect(function(key) end)
	
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Signal = require(Shared:WaitForChild("Signal")) 

local Knit = require(ReplicatedStorage.Packages.Knit)

local UserInput = Knit.CreateController({
	Name = "UserInput",

	HideMouse = false,

	Preferred = {
		Keyboard = 0;
		Mouse = 1;
		Gamepad = 2;
		Touch = 3;
	},

	ProcessInput = Signal.new() 

})


local modules = {}
local userInput = game:GetService("UserInputService")

function UserInput:Get(moduleName)
	return modules[moduleName]
end

function UserInput:GetPreferredModule()
	local _pref = self._preferred 

	for _moduleName, num in pairs(self.Preferred) do 
		if (num == _pref) then 
			return self:Get(_moduleName) 
		end 
	end 
end 

function UserInput:KnitInit()

	for _,obj in ipairs(script:GetChildren()) do
		if obj:IsA("ModuleScript") then
			local module = require(obj)
			modules[obj.Name] = module

			if module.Start then 
				module:Start() -- Begin recording output. 
			end 
		end
	end
	
	local function SetMouseIconEnabled(enabled)
		if self.HideMouse then
			userInput.MouseIconEnabled = enabled
		end
	end

	local function ChangePreferred(newPreferred)
		if (self._preferred ~= newPreferred) then
			self._preferred = newPreferred
			self.PreferredChanged:Fire(newPreferred)
			if (newPreferred == self.Preferred.Mouse or newPreferred == self.Preferred.Keyboard) then
				SetMouseIconEnabled(true)
			else
				SetMouseIconEnabled(false)
			end
		end
	end

	local function LastInputTypeChanged(lastInputType)
		if (lastInputType.Name:match("^Mouse")) then
			ChangePreferred(self.Preferred.Mouse)
		elseif (lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.TextInput) then
			ChangePreferred(self.Preferred.Keyboard)
		elseif (lastInputType.Name:match("^Gamepad")) then
			ChangePreferred(self.Preferred.Gamepad)
		elseif (lastInputType == Enum.UserInputType.Touch) then
			ChangePreferred(self.Preferred.Touch)
		end
	end

	userInput.LastInputTypeChanged:Connect(LastInputTypeChanged)
	self.PreferredChanged = Signal.new()

	if (game:GetService("GuiService"):IsTenFootInterface()) then
		ChangePreferred(self.Preferred.Gamepad)
	elseif (userInput.TouchEnabled) then
		ChangePreferred(self.Preferred.Touch)
	else
		ChangePreferred(self.Preferred.Keyboard)
	end

end


function UserInput:GetPreferred()
	return self._preferred
end


return UserInput
