-- Round
-- @ocula
-- July 4, 2021

local Round = {}
Round.__index = Round

function Round.new()
	local self = setmetatable({}, Round)

	return self
end

return Round
