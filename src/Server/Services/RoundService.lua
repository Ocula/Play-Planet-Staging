-- Need to add support for matchmaking
-- Idea: Make match joining areas a collectionservice thing
-- This service will keep the players in those areas up to date as well as countdowns
-- It will also start those matches, but that's about it. It won't handle their cancellations.
-- It might however observe ongoing data to ensure that we aren't creating too many matches per server.

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies
local Binder = require(Knit.Library.Binder)
local Area = require(Knit.Modules.Round.Area)
local Maid = require(Knit.Library.Maid)

local RoundService = Knit.CreateService({
	Name = "RoundService",
	Areas = {},
	Client = {
		PlayerListChanged = Knit.CreateSignal(),
		CountdownChanged = Knit.CreateSignal(),
		PlayerLobbyStatusChanged = Knit.CreateSignal(),
	},

	_maid = Maid.new(),
	_breakCheck = false,
})

function RoundService:CheckAreas()
	local PlayerService = Knit.GetService("PlayerService")
	local LobbyPlayers = PlayerService:GetPlayersInLobby()

	for _, area in pairs(self.Areas) do
		for _, player in pairs(LobbyPlayers) do
			area:Check(player)
		end
	end
end

-- Should only be used in sparing conditions.
function RoundService:BreakLoop()
	self._maid:DoCleaning()
end

function RoundService:startLoop()
	self._maid:GiveTask(RunService.Heartbeat:Connect(function()
		self:CheckAreas()
	end))
end

function RoundService:KnitStart()
	-- Index in new Round areas.
	local roundAreaBinder = Binder.new("RoundArea", Area.new)

	roundAreaBinder:GetClassAddedSignal():Connect(function(newArea)
		if newArea._ShellClass then
			return
		end

		if self.Areas[newArea.Object] then
			return
		end

		self.Areas[newArea.Object] = newArea
	end)

	roundAreaBinder:Start()

	--

	self:startLoop()
end

function RoundService:KnitInit() end

return RoundService
