-- Obstacle Controller
-- Username
-- December 24, 2020

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shared = ReplicatedStorage:WaitForChild("Shared") 

local ObstacleController = Knit.CreateController({
    Name = "ObstacleController",
    Active = {};
})

function ObstacleController:Get(Obstacle)
    for i,v in pairs(self.Active) do
        if v.Object == Obstacle then 
            return v, i
        end
    end
end

function ObstacleController:KnitStart()
    local Binder = require(Shared.Binder)
    local Obstacle = Binder.new("ObstacleObject", require(Knit.Modules.Classes.ObstacleObject))

    Obstacle:GetClassAddedSignal():Connect(function(newClass) 
		warn("Obstacle Object") 
        if (newClass and not newClass._ShellClass) then 
            self.Active[newClass.Object] = newClass 
        end 
    end) 

    Obstacle:Start() 
end

function ObstacleController.AnimateSpringPad(pad)
	--Get parts
	local base = pad.Base
	local spring = pad.Spring
	pad = pad.Pad

	--Function to set the height of the pad
	local function setHeight(h)
		if (spring and pad and spring:FindFirstChild("Mesh")) then 
			pad.CFrame = base.CFrame * CFrame.new(0, 0.5 + h, 0)
			spring.CFrame = base.CFrame * CFrame.new(0, 0.125 + h/2, 0) * CFrame.Angles(math.pi/2, 0, 0)
			spring.Mesh.Scale = Vector3.new(1.5, 1.5, h/3.425)
		end
	end

	--Expansion
	local height = 3
	local tLength = 3
	local tStart = os.clock()
	local tEnd = tStart + tLength
	local frequency = 5*(math.pi*2)
	local decay = 5

	while (tEnd > os.clock()) do
		RunService.RenderStepped:wait()
		--Calculate time elapsed
		local tElapsed = os.clock() - tStart

		--Calculate position
		local baseOsc = math.cos((tElapsed*frequency) % (2*math.pi))
		local factor = math.exp(-decay*tElapsed)
		local pos = height * (1-baseOsc*factor)

		setHeight(pos)
	end

	wait(1)
	tLength = 1
	tStart = os.clock()
	tEnd = tStart + tLength

	while (tEnd > os.clock()) do
		RunService.RenderStepped:wait()
		--Calculate time elapsed
		local tElapsed = os.clock() - tStart

		--Calculate position
		local progress = tElapsed/tLength
		local pos = math.pow(math.cos(progress*math.pi/2),2)*height

		setHeight(pos)
	end
	setHeight(0)
end

return ObstacleController