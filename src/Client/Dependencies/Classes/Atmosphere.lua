-- Atmosphere Class
-- @ocula
-- December 15, 2020
--  Ported to Knit: June 7, 2023
--  Play Planet

local AtmosphereClass = {}
AtmosphereClass.__index = AtmosphereClass


function AtmosphereClass.new(Skybox)
	
	local _Center 		= Skybox:WaitForChild("Center") 
	local _Settings 	= _Center:WaitForChild("Settings") 

	local Transparency 	= _Settings:FindFirstChild("Transparency")
	local Radius 		= _Settings:FindFirstChild("Radius") 

	local self = setmetatable({
		Object       = Skybox,
		Radius       = (Radius or {Value = 150}).Value,
		Transparency = (Transparency or {Value = 0}).Value
	}, AtmosphereClass)

	return self 
end

function AtmosphereClass:Update()
    local Player = game.Players.LocalPlayer 

	local distance = (Player.Character.HumanoidRootPart.Position - self.Object.PrimaryPart.Position).Magnitude
	local measureRadius = self.Radius - 100 

	if distance > measureRadius then
		local progress = distance - measureRadius 
		local currTransparency = progress / ((self.Radius - (self.Radius*0.25)) - measureRadius)

		for i,v in pairs(self.Object:GetChildren()) do
			if v.Name ~= "Center" then
				v.Decal.Transparency = currTransparency - self.Transparency 
			end
		end
	else
		for i,v in pairs(self.Object:GetChildren()) do
			if v.Name ~= "Center" then
				v.Decal.Transparency = self.Transparency
			end
		end
	end
end

function AtmosphereClass:Destroy()
	return true 
end 

return AtmosphereClass