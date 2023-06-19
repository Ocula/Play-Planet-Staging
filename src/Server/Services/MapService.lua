local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MapService = Knit.CreateService({
	Name = "MapService",
	Maps = {},
	Slots = {},
	Client = {},
})

-- We'll put everything up at 300 studs?
-- Spread 'em out for now by like 100 studs. We'll see.

function MapService:add(Map)
	self.Maps[Map.MapId] = Map
end

function MapService:remove(MapId)
	self.Maps[MapId] = nil
end

function MapService:getSlot()
	for i, slot in pairs(self.Slots) do
		if slot.inUse == false then
			return slot
		end
	end
end

function MapService:KnitStart() end

function MapService:KnitInit()
	-- Create slots... 32 slots is realistically the most that will ever be used. But 42 is a safe bet.
	local slotIndex = 1

	local x = -1000

	for z = -1000, 1000, 50 do -- Z position essentially
		x += 50
		local newX, newY = x, 300

		self.Slots[slotIndex] = { inUse = false, CFrame = CFrame.new(x, y, z) }

		slotIndex += 1
	end

	--print(slotIndex, "Map Slots created", self.Slots)
end

return MapService
