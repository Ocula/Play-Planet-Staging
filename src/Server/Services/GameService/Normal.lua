-- Normal
-- @ocula
-- July 4, 2021

--[[

    Normal round for Puzzle-based Round game.

    12 players maximum
    5 puzzles needed to solve to escape (calibrated to player count)

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)

local Normal = {}
Normal.__index = Normal

-- // Public methods & functions
function Normal.new(Data)
	local self = setmetatable({
		Name = Data.Name or "Round",

		-- Required Variables
		GameId = Data.GameId,
		Spawns = Data.Spawns,
		Exits = Data.Exits,
		Puzzles = Data.Puzzles,
		Map = Data.Map,
		Time = Data.Time,
		Players = Data.Players,

		-- Optional Variables
		RewardLimit = Data.RewardLimit or 5,
		Countdown_Var = Data.Countdown or 3,
		TimeFormat = Data.TimeFormat or "Minutes:Seconds", -- "Minutes:Seconds"

		_countdownSignal = Signal.new(),
		_playerLeft = Signal.new(),
		_playerDied = Signal.new(),

		-- Internal
		DebounceCheck = os.clock(),

		-- Reward Variables - Revitalize Lottery Wheels for this game
		Rewards = Data.Rewards
			or {
				Type = "Lottery_Items",
				Items = {
					Rarest = { Number = 1, {} }, -- This should be really hard to swing
					UltraRare = { Number = 1, {} },
				},
				Uncommon = { Number = 2, {} }, -- Theoretically because there are 2 uncommon sections, these should be easiest to swing
				Common = { Number = 1, {} },
			},
	}, Normal)

	self._playerLeft:Connect(function(_player)
		for index, value in pairs(self.Players) do
			if value == _player then
				if value._isEvil then
					warn("Player that left was the villain character.")
				end

				self.Players[index] = nil

				warn("Round registered player leave:", _player, self.Shared.Utility:CountTable(self.Players))
			end
		end
	end)

	self._playerDied:Connect(function(_player)
		for index, value in pairs(self.Players) do
			if value == _player then
				self.Players[index] = nil
			end
		end
	end)

	return self
end

function Normal:ProcessResponse(Player, Response)
	local _SessionId = self:GetSessionIdFromPlayer(Player)
	local _Session = self.Sessions[_SessionId]

	if _Session then
		--warn("SessionId:", _SessionId, _Session)
		_Session.Players[Player].Completed = Response
	end
end

function Normal:ProcessCountdownComplete(Player) end

-- Method for setting up the round
-- Handles teleporting, staging the map, setting puzzles, etc
-- Parameters: Players [array]
function Normal:Setup()
	local Players = self.Players

	-- Setup Map
	local _map = self.Map
	_map:Create()

	_map:SetSpawns()

	-- Puzzles
	local _playerCount = self.Shared.Utility:CountTable(Players)
	local _puzzleCount = math.ceil(_playerCount / 3)

	--// testing

	_puzzleCount = 5

	_map:SetPuzzles(_puzzleCount)
	_map:SetSpawns()

	-- Players
	local _setPlayers = 0

	for i, v in pairs(Players) do
		spawn(function()
			local _success = Knit.GetService("SpawnService"):GetRandomSpawn()
			_success:Teleport(v, 1)

			print("unfiltered table:", Knit.GetService("SpawnService").Spawns)

			if _success then
				_setPlayers += 1
			end
		end)
	end

	repeat
		wait()
	until _setPlayers == self.Shared.Utility:CountTable(Players)

	return true
end

function Normal:CheckPuzzles()
	local _check = 0

	for i, v in pairs(self.Puzzles) do
		if v:isDone() then
			_check += 1
		end
	end

	-- TODO // Create a self.Puzzle_Total variable
	if _check == self.Puzzle_Total then
		return true
	else
		return false
	end
end

-- Method for checking if a player has met the conditions for victory.
-- Returns true if the player has won, false if otherwise / still in progress.
-- Parameters: Player [instance]
function Normal:CheckPlayer(Player)
	if Player and Player.Character then
		Knit.GetService.MinigamesService.ClientCheck:Fire(Player, self.MinigameId)

		local _SessionId, _classPlayer = self:GetSessionIdFromPlayer(Player)
		return _classPlayer.Completed
	end

	return false
end

-- Method to handle end of minigame processes.
-- Parameters: Player instancequire()
function Normal:EndPlayer(Player, Status)
	local HRP = Player.Character:FindFirstChild("HumanoidRootPart")

	if Player and HRP then
	end
end

-- Method to trigger Minigame countdown for a set of players.
-- Parameters: Players [array]
-- @Countdown is a method that is required to be called in every minigame. It also handles sending PlayerReady data.
function Normal:Countdown(Players)
	-- Show game title, then countdown (this is all in one method: MinigameService:FireClient("Countdown", Player, Time, Game_Name))
	-- Server should handle control access.
	for i, v in pairs(Players) do
		Knit.GetService("GameService"):FireClient("Countdown", v.Player)
	end
end

function Normal:Clean()
	for i, v in pairs(self.Players) do
		v._activeSpawn = nil
		v:Spawn()
	end

	self.Map:Destroy()
	warn("Ending round")
end

-- // Private methods (_ notation)

-- Method for starting a new game session.
-- Supports multiple players, but since the client will be initiating sessions,
-- games will be solo most of the time. Server-run multiplayer sessions are supported.

-- Parameters: Players [array]
function Normal:Play()
	self.TimeLeft = self.TimeLeft or 5

	local Players = self.Players
	local _counted = {}

	-- Make sure that players that leave are taken out. Imperative for multiplayer games.
	game:GetService("Players").PlayerRemoving
		:Connect(
			function(Player) -- This will likely be handled by GameService / PlayerService for this game specifically
				if Players[Player.userId] then
					Players[Player.userId] = nil
				end
			end
		)

	------ // Setup/Countdown

	self:Setup(Players) -- Get players ready.

	wait(1)

	self._countdownSignal:Connect(function(_player)
		if not _counted[_player.userId] then
			_counted[_player.userId] = true
		end
	end)

	self:Countdown(Players) -- Countdown on all the players.

	repeat
		task.wait()
	until self.Shared.Utility:CountTable(_counted) == self.Shared.Utility:CountTable(Players) -- Wait until players are ready. Countdown on Minigame Controller will always send a Ready request to the server.

	self.TimeLeft += 0.99

	local _debounce = os.clock()
	local sessionLoop
	sessionLoop = game:GetService("RunService").Stepped:Connect(function(t, step)
		-- Update Time
		self.TimeLeft -= step

		if os.clock() - _debounce > 0.1 then
			_debounce = os.clock()

			print(self.TimeLeft)

			if
				(
					self.TimeLeft <= 0
					or self.Shared.Utility:CountTable(self.Players)
						< Knit.GetService("GameService")._amountNeededPerRound
				) and not self.Finished
			then
				self.Finished = true

				self:Clean()

				Knit.GetService("GameService")._inSession = false
				Knit.GetService("GameService")._roundOver:Fire()

				sessionLoop:Disconnect()
			end
		end
	end)
end

return Normal
