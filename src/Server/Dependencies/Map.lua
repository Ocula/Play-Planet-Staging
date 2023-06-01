-- Map
-- @ocula
-- July 4, 2021

local Map = {}
Map.__index = Map

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)
local Maid = require(Knit.Library.Maid)

function Map.new(data)
	local MapService = Knit.GetService("MapService")

	local self = setmetatable({
		MapId = data.MapId or HttpService:GenerateGUID(false),
		Map = data.Map:Clone(),
		Spawns = {},

		_maid = Maid.new(),
		-- Puzzles = {}, 	-- Deprecated
		-- Exits = {}, 		-- Deprecated
	}, Map)

	MapService:add(self)

	return self
end

-- Get Map spawns
function Map:GetSpawns()
	return self.Spawns
end

-- Get Map puzzles
function Map:GetPuzzles()
	return self.Puzzles
end

-- Get Exits
function Map:GetExits()
	return self.Exits
end

function Map:SetCFrame(cf)
	local obj = self.Map
	if obj then
		obj:PivotTo(cf)
	end
end

function Map:GetCFrame()
	local obj = self.Map
	if obj then
		return obj:GetBoundingBox()
	end
end

function Map:GetOpenSpawn()
	warn("Getting open spawn")

	for i, v in pairs(self.Spawns) do
		if not v:isBusy() then
			warn("Found", v)
			return v
		end
	end
end

-- Set Spawn
function Map:SetSpawns()
	local _spawns = {}
	local _obj = self.Map

	for _, v in pairs(Knit.GetService("SpawnService").Spawns) do
		local _parent = Utility:FindParent(v.Object, _obj)
		if _parent then
			table.insert(_spawns, v)
		end
	end

	self.Spawns = _spawns
end

function Map:Create() -- Need to create back/front walls
	local MapService = Knit.GetService("MapService")
	local mapSlot = MapService:getSlot()

	mapSlot.inUse = true

	local _obj = self.Map
	_obj.Parent = workspace

	self:SetCFrame(mapSlot.CFrame)

	self._slot = mapSlot

	return _obj
end

function Map:Destroy()
	self._maid:DoCleaning()

	for _, v in pairs(self.Spawns) do
		v:Destroy()
	end

	if self.Map then
		self.Map:Destroy()
	end

	self._slot.inUse = false
end

return Map

-- Deprecated (used to Set Puzzle objects in a map)
--[[
function Map:SetPuzzles(_number)
	local _obj = self.Object
	local _puzzles = {}

	local _totalLeft = _number
	local _totalToChooseFrom = {}

	local rng = Random.new(os.time())

	local function shuffle(array)
		local item
		for i = #array, 1, -1 do
			item = table.remove(array, rng:NextInteger(1, i))
			table.insert(array, item)
		end
	end

	-- Make sure the puzzles we're sorting are in our map.

	for _, v in pairs(Knit.GetService("PuzzleService").Puzzles) do
		local _parent = Knit.Modules.Utility:FindParent(v.Object, _obj)

		if _parent then
			table.insert(_totalToChooseFrom, v)
		end
	end

	-- Shuffle!
	shuffle(_totalToChooseFrom)

	-- Aggregate.
	for i = 1, _totalLeft do
		local _backupPuzzleChosen = _totalToChooseFrom[i]
		_backupPuzzleChosen.Active = true
	end

	for i, v in pairs(_totalToChooseFrom) do
		if not v.Active then
			v:Destroy()
		end

		_totalToChooseFrom[i] = nil
	end

	self.Puzzles = _totalToChooseFrom
end--]]
