-- Mouse
-- Stephen Leitnick / @Ocula
-- December 28, 2017 / June 8, 2023

--[[
	
	Vector2        Mouse:GetPosition()
	Vector2        Mouse:GetDelta()
	Void           Mouse:Lock()
	Void           Mouse:LockCenter()
	Void           Mouse:Unlock()
	Ray            Mouse:GetRay(distance)
	Ray            Mouse:GetRayFromXY(x, y)
	Void           Mouse:SetMouseIcon(iconId)
	Void           Mouse:SetMouseIconEnabled(isEnabled)
	Boolean        Mouse:IsMouseIconEnabled()
	Boolean        Mouse:IsButtonPressed(mouseButton)
	RaycastResult  Mouse:Raycast(raycastParams [, distance = 1000])
	
	Mouse.LeftDown()
	Mouse.LeftUp()
	Mouse.RightDown()
	Mouse.RightUp()
	Mouse.MiddleDown()
	Mouse.MiddleUp()
	Mouse.Moved()
	Mouse.Scrolled(amount)
	
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Shared = ReplicatedStorage:WaitForChild("Shared") 

local Mouse = {}

local RAY_DISTANCE = 1000

local playerMouse = game:GetService("Players").LocalPlayer:GetMouse()
local userInput = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local workspace = workspace


function Mouse:GetPosition()
	return userInput:GetMouseLocation()
end


function Mouse:GetDelta()
	return userInput:GetMouseDelta()
end


function Mouse:Lock()
	userInput.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end


function Mouse:LockCenter()
	userInput.MouseBehavior = Enum.MouseBehavior.LockCenter
end


function Mouse:Unlock()
	userInput.MouseBehavior = Enum.MouseBehavior.Default
end


function Mouse:SetMouseIcon(iconId)
	playerMouse.Icon = (iconId and ("rbxassetid://" .. iconId) or "")
end


function Mouse:SetMouseIconEnabled(enabled)
	userInput.MouseIconEnabled = enabled
end


function Mouse:IsMouseIconEnabled()
	return userInput.MouseIconEnabled
end


function Mouse:IsButtonPressed(mouseButton)
	return userInput:IsMouseButtonPressed(mouseButton)
end


function Mouse:GetRay(distance)
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction * distance)
end


function Mouse:GetRayFromXY(x, y)
	local viewportMouseRay = cam:ViewportPointToRay(x, y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction)
end

function Mouse:Raycast(raycastParams, distance)
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return workspace:Shapecast(viewportMouseRay.Origin, 3, viewportMouseRay.Direction * (distance or RAY_DISTANCE), raycastParams)
end


function Mouse:Start()
	local Signal = require(Shared:WaitForChild("Signal"))
	local ToolController = Knit.GetController("ToolController") 

	self.LeftDown   = Signal.new()
	self.LeftUp     = Signal.new()
	self.RightDown  = Signal.new()
	self.RightUp    = Signal.new()
	self.MiddleDown = Signal.new()
	self.MiddleUp   = Signal.new()
	self.Moved      = Signal.new()
	self.Scrolled   = Signal.new()
	
	userInput.InputBegan:Connect(function(input, processed)
		--if (processed) then return end
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleDown:Fire()
		end

		ToolController:ProcessInput(input, processed) 
	end)
	
	userInput.InputEnded:Connect(function(input, _processed)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleUp:Fire()
		end

		ToolController:ProcessInput(input, _processed) 
	end)
	
	userInput.InputChanged:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then
			self.Moved:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseWheel) then
			if (not processed) then
				self.Scrolled:Fire(input.Position.Z)
			end
		end

		ToolController:ProcessInput(input, processed) 
	end)
	
end


return Mouse
