-- Atmosphere
-- @ocula 
-- December 15, 2020 (Toy Planet) 
--  Ported to Knit: June 7, 2023 
--  Play Planet

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Atmosphere = Knit.CreateController{
    Name = "AtmosphereController", 
    Atmospheres = {};
}

function Atmosphere:GetAtmosphere(Obj)
    for i,v in pairs(self.Atmospheres) do
        if v.Object == Obj then
            return v, i
        end
    end
end

function Atmosphere:GetClosestAtmosphericField() -- TODO: Make cleaner - switch over to a Octree check
    local Player = game.Players.LocalPlayer 

    for _,v in pairs(self.Atmospheres) do
        if Player.Character then 
            if v.Object:FindFirstAncestor("Workspace") and Player.Character:FindFirstChild("HumanoidRootPart") then
                if (v.Object.PrimaryPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude < v.Radius then
                    return v
                end
            end
        end 
    end
end

function Atmosphere:OnStep(dt)
    local nearestField = Atmosphere:GetClosestAtmosphericField()
    if nearestField then
        nearestField:Update()
    end
end

function Atmosphere:KnitStart()
    local Binder = require(Knit.Library.Binder)

    local atmosBinder = Binder.new("Atmosphere", require(Knit.Modules.Classes.Atmosphere))

	atmosBinder:GetClassAddedSignal():Connect(function(Atmos)
		if (Atmos and not Atmos._ShellClass) then
			if self.Atmospheres[Atmos.Object] then warn("Atmos class already created for that atmosphere.", Atmos.Object:GetFullName()) return end 
			self.Atmospheres[Atmos.Object] = Atmos 
        end 
	end)

    game:GetService("RunService"):BindToRenderStep("Atmosphere", Enum.RenderPriority.Last.Value, self.OnStep)

    atmosBinder:Start() 
end


function Atmosphere:KnitInit()
	
end


return Atmosphere