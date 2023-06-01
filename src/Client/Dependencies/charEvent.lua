-- Character Event class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local charEvent = {}
charEvent.__index = charEvent

function charEvent.new(_event)
	local _new = {
		Name = _event.Name,
		Bind = Signal.new(),
		EventType = _event.Type,
	}

	_new.Bind:Connect(_event.Fired)

	local self = setmetatable(_new, charEvent)
	return self
end

function charEvent:Destroy() end

return charEvent
