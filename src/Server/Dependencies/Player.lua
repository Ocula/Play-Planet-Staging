-- Player
-- @ocula
-- July 4, 2021
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Library.Promise)
local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid)

local Player = {}
Player.__index = Player

--[[
	local tabletest = {} 
	tabletest.__index = tabletest 

	function tabletest.new()
		return setmetatable({}, tabletest)
	end

	function tabletest:__newindex(a, b, c) 
		print("NewIndex called")
		rawset(self, a, b)
	end

	function tabletest:__index(a, b, c)
		print("Index called")
		print(a, b, c)
	end 
	
	local test = tabletest.new()

	test.Hello = 1

	local _test = test[
	print(_test)

]]

function Player.new(_player, _profile)
	if not _profile then
		warn("No profile provided for player:", _player, "... exiting.")
		return
	end

	local RoundService = Knit.GetService("RoundService")

	local self = setmetatable({
		Player = _player,
		Lobby = false,
		Image = Players:GetUserThumbnailAsync(
			_player.UserId,
			Enum.ThumbnailType.AvatarBust,
			Enum.ThumbnailSize.Size180x180
		),
		Game = {
			DamageTaken = 0, -- per match
			DamageGiven = 0, -- per match

			_totalDamageTaken = _profile.TotalDamageTaken,
			_totalDamageGiven = _profile.TotalDamageGiven,
		},

		Humanoid = {},

		PropertyChangedSignal = Signal.new(),
		Leaving = Signal.new(),

		_disableEvents = false,
		_sessionId = "",
		_maid = Maid.new(),
	}, Player)

	-- Reconcile player profile:
	for _saveIndex, _saveValue in pairs(_profile.Data) do
		self[_saveIndex] = _saveValue
	end

	self.PropertyChangedSignal:Connect(function(property, value)
		-- Handle property changes.
		if property == "Lobby" then
			local RoundService = Knit.GetService("RoundService")
			RoundService.Client.PlayerLobbyStatusChanged:Fire(_player, value)
		end
	end)

	self.Leaving:Connect(function()
		-- Find any existing sessions or instances.
		if self._sessionId then
			-- get GameRound and make sure to call an Exit on that
			local GameService
		end

		if self.Lobby then
			self.Lobby = false -- So we don't get added again on accident.
			-- check the Area objects
			for _, area in pairs(RoundService.Areas) do
				if area.Players[_player] then
					area:_remove(self)
				end
			end
		end

		if _profile then
			_profile:Release()
		end

		self._maid:DoCleaning()
	end)

	return self
end

-- Disables all Player Events on the Player. Important for when we have no player character on purpose.
function Player:Disable()
	self._disableEvents = true
end

function Player:Enable()
	self._disableEvents = false
end

function Player:SetJumpHeight(num)
	self.Humanoid.JumpHeight = num -- Set this on the server so any time our player Humanoid regenerates, we have the value saved.

	local char = self.Player.Character

	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.JumpHeight = num
			warn("Setting JumpHeight of", self.Player, "to", hum.JumpHeight)
		end
	end
end

function Player:SetCameraState(...)
	local GameService = Knit.GetService("GameService")
	GameService.Client.SetCameraState:Fire(self.Player, ...)
end

function Player:connectCharacterEvents(player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")

		for property, value in pairs(self.Humanoid) do
			humanoid[property] = value
		end

		humanoid.Died:Connect(function()
			if self._disableEvents then
				return
			end

			self.Player.Character = nil

			task.spawn(function()
				self:Spawn()
			end)
		end)
	end
end

function Player:Spawn()
	if not self.Player.Character then
		self.Player:LoadCharacter()
		self:connectCharacterEvents(self.Player)
	end

	local SpawnService = Knit.GetService("SpawnService")

	if not self._activeSpawn then
		SpawnService:LobbySpawn(self.Player)

		if not self.Lobby then
			self.Lobby = true
			self.PropertyChangedSignal:Fire("Lobby", true)
		end
	else
		self._activeSpawn:Teleport(self)
	end
end

function Player:Kick()
	self.Player:Kick()
end

function Player:Reset() end

function Player:Exit() end

function Player:Save() end

function Player:Interface() end

return Player
