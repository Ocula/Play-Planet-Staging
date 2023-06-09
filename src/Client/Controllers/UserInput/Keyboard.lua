-- Keyboard
-- Stephen Leitnick
-- December 28, 2017

--[[
	
	Boolean   Keyboard:IsDown(keyCode)
	Boolean   Keyboard:AreAllDown(keyCodes...)
	Boolean   Keyboard:AreAnyDown(keyCodes...)
	
	Keyboard.KeyDown(keyCode)
	Keyboard.KeyUp(keyCode)
	
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Keyboard = {}

local userInput = game:GetService("UserInputService")


function Keyboard:IsDown(keyCode)
	return userInput:IsKeyDown(keyCode)
end


function Keyboard:AreAllDown(...)
	for _,keyCode in pairs{...} do
		if (not userInput:IsKeyDown(keyCode)) then
			return false
		end
	end
	return true
end


function Keyboard:AreAnyDown(...)
	for _,keyCode in pairs{...} do
		if (userInput:IsKeyDown(keyCode)) then
			return true
		end
	end
	return false
end

-- @ocula
-- Begin recording Keyboard input
function Keyboard:Start()
	local Signal = require(Shared:WaitForChild("Signal"))
	local ToolController = Knit.GetController("ToolController") 
	
	self.KeyDown = Signal.new()
	self.KeyUp = Signal.new()
	
	userInput.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			self.KeyDown:Fire(input.KeyCode)
			--ToolController:ProcessInput(input, processed) 
		end
	end)
	
	userInput.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			self.KeyUp:Fire(input.KeyCode)
			--ToolController:ProcessInput(input, processed) 
		end
	end)
end


return Keyboard