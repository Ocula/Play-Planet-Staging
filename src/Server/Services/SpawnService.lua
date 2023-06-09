-- Spawn Service
-- @ocula
-- July 15, 2021

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local SpawnService = Knit.CreateService({
	Name = "SpawnService",
	Client = {},
	Spawns = {},
})

function SpawnService:KnitStart() end

function SpawnService:KnitInit()
	local _binder = require(Knit.Library.Binder)
	local _spawnBinder = _binder.new("Spawn", require(Knit.Modules.Spawn).new)

	_spawnBinder:GetClassAddedSignal():Connect(function(Spawn)
		if Spawn and not Spawn._ShellClass then
			if self.Spawns[Spawn.Object] then
				warn("Spawn class already created for that Spawn.", Spawn.Object:GetFullName())
				return
			end

			self.Spawns[Spawn.Object] = Spawn
		end
	end)

	_spawnBinder:Start()
end

function SpawnService.getLobbySpawns()
	local _spawns = {}

	for i, v in pairs(game:GetService("CollectionService"):GetTagged("Spawn")) do
		if v:GetAttribute("Lobby") then
			table.insert(_spawns, v)
		end
	end

	return _spawns
end

function SpawnService:LobbySpawn(_player)
	local _spawns = self.getLobbySpawns()
	local _spawn = _spawns[math.random(1, #_spawns)]

	local state = _spawn:GetAttribute("SetState") 

	if state then -- This spawn is in a different Gravity place. 
		local PlayerService = Knit.GetService("PlayerService")
		local Player = PlayerService:GetPlayer(_player) 

		assert(Player, "Player was not indexed into the server properly.") 

		Player:SetState(state)
	end

	Utility:TeleportPlayer(_player, _spawn.CFrame, 0)
end

function SpawnService:GetRandomSpawn(_villain)
	local _filteredTable = self.Shared.Utility:FilterTable(self.Spawns, function(_value)
		return _value.Villain == _villain
	end)

	local _count = self.Shared.Utility:CountTable(_filteredTable)
	local _rand = math.random(1, _count)

	local _num = 0
	for _, spawn in pairs(_filteredTable) do
		_num += 1

		if _num == _rand then
			return spawn
		end
	end
end

return SpawnService
