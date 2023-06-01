-- This is here to init the folder into existence lol
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Handler = require(Knit.Modules.Interface.get)

local Effect = {}
Effect.__index = Effect

function Effect.new(effectName)
	return Handler:Get("Effect/" .. effectName)
end

return Effect
