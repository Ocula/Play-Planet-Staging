--[[
    Free For All by @ocula 

    Jun 18, 2023

    Handle Play Planet Free For All Logic

    Todo: Write API Reference Sheet
--]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies
local Map = require(Knit.Modules.Map)
local Signal = require(ReplicatedStorage.Shared.Signal)
local Maid = require(ReplicatedStorage.Shared.Maid) 

local freeForAll = {}
freeForAll.__index = freeForAll

function freeForAll.new(data)
	local self = setmetatable({
		-- Match Spawn, Map, & Player Data
		Players = data.Players,
		Map = data.Map, -- To force map. But we'll give players option to choose.
		Spawns = data.Map.Spawns,

		-- Free For All Data
		Time = 180, -- 3 mins
		Damage = { Min = 0, Max = 300 }, -- So we can change

		-- Internal
		SessionId = HttpService:GenerateGUID(false),
		Session = {},

        PlayerReady = Signal.new(),

        _allReady = Signal.new(), -- Internal event 
        _maid = Maid.new(),
	}, freeForAll)

    self.PlayerReady:Connect(function(player)
        local _total = 0 
        local _ready = 0

        for i,v in pairs(self.Players) do 
            _total += 1 

            if v.Player == player then 
                v._isReady = true 
            end 

            if v._isReady then 
                _ready += 1 
            end 
        end 

        if _ready == _total then
            self._allReady:Fire() 
        end 
    end)
	-- Set Internal Data

	return self
end

function freeForAll:GetSpawn(player)
	if not player._activeSpawn then
		player._activeSpawn = self.Map:GetRandomSpawn()
	end

	return player._activeSpawn
end

function freeForAll:GetSessionId()
	return self.SessionId
end

function freeForAll:GetRawPlayers()
	local players = {}

	for i, v in pairs(self.Players) do
		table.insert(players, v.Player)
	end

	return players
end

function freeForAll:add(player) -- Can be fed an AI object or Player object
	-- AI object will mimic the player object so that all methods are the same.
	-- Attach SessionId to player

    -- Check if player already exists.
    for i,v in pairs(self.Players) do 
        if v.Player == player then
            return 
        end 
    end 

    table.insert(self.Players, player) 
end

function freeForAll:Countdown() -- This might be better streamlined into GameService
    local Countdown = require(Knit.Modules.Countdown).new(3) 
    -- Wait for player ready so we know they're ready for a countdown.
    self._allReady:Wait() 
end

function freeForAll:Setup()
	for i, v in pairs(self.Players) do
		v.Lobby = false
		v:SetJumpHeight(10)

		--task.spawn(function()
		local spawn = self.Map:GetOpenSpawn()
		local cf, size = self.Map:GetCFrame()
		--v:SetSpawn(spawn)
		v._activeSpawn = spawn
		v:Spawn()

		v:SetCameraState("Game", self:GetRawPlayers(), cf, size)
		--end)
	end
end

function freeForAll:Play() end

return freeForAll
