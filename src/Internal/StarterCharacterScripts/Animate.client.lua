-- Animate.lua (placed under StarterCharacterScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Module = ReplicatedStorage.Packages:WaitForChild("character-animate")
local CharacterAnimate = require(Module) 

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local controller = CharacterAnimate.animate(script, humanoid)

--[[
script:WaitForChild("PlayEmote").OnInvoke = function(emote)
	return controller.playEmote(emote)
end--]]