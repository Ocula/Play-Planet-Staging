-- Manages all UI transitions (Fade ins, outs)
--[[

API
    Fade:into() -- table: {type = "Basic", time = number}
    Fade:out()

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fade = {
	_currentFadeObject = nil, -- This is the Fade object that we want to control when fading out.
}

function Fade:to() end

function Fade:out() end

return Fade
