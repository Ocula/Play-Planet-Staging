--[=[ 
    Match by @ocula
    
    Jan 11, 2022

    Handles all Match logic.
--]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies
local Map = require(Knit.Modules.Map)

local Match = {}
Match.__index = Match

function Match.new(data)
	local self = setmetatable({
		-- Match Spawn, Map, & Player Data
		Players = data.Players,
		Map = data.Map, -- To force map. But we'll give players option to choose.
		Spawns = data.Map.Spawns,

		-- Match Data
		Time = 180, -- 3 mins
		Stocks = 3,
		Damage = { Min = 0, Max = 300 }, -- So we can change

		-- Internal
		SessionId = HttpService:GenerateGUID(false),
		Session = {},
	}, Match)

	-- Set Internal Data

	return self
end

function Match:GetSpawn(player)
	if not player._activeSpawn then
		player._activeSpawn = self.Map:GetRandomSpawn()
	end

	return player._activeSpawn
end

function Match:GetSessionId()
	return self.SessionId
end

function Match:GetRawPlayers()
	local players = {}

	for i, v in pairs(self.Players) do
		table.insert(players, v.Player)
	end

	return players
end

function Match:add(player) -- Can be fed an AI object or Player object
	-- AI object will mimic the player object so that all methods are the same.
	-- Attach SessionId to player
end

function Match:Countdown()
	local GameService = Knit.GetService("GameService")
end

function Match:Setup()
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

function Match:Play() end

return Match
