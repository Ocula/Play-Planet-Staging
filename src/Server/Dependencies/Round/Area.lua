-- Round.Area.lua
-- @ocula / Jan 11, 2022
-- Used for Round Area objects.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies
local OverlapCheck = require(Knit.Library.OverlapCheck) 

local Area = {}
Area.__index = Area

function Area.new(part)
	local _maid = require(Knit.Library.Maid)

	local self = setmetatable({
		Object = part,
		Players = {},

		_disabled = false, -- Debounce
		_maid = _maid.new(),
	}, Area)

	-- Get attributes and add in.
	for i, v in pairs(part:GetAttributes()) do
		self[i] = v
	end

	-- Set countdown
	self._countdown = self.Countdown

	-- Create Region
	self._region = OverlapCheck.new(part)

	self._maid:GiveTask(self._region) 

	return self
end

function Area:GetRegion()
	return self._region
end

function Area:Disable()
	self._disabled = true
	self:Reset()

	self:_countChanged()
end

function Area:Enable()
	self._disabled = false
end

function Area:Reset()
	self._countdown = self.Countdown
	self.Players = {}

	self:_listChanged()
end

function Area:StartCount()
	local GameService = Knit.GetService("GameService")

	if self._count then
		return
	end

	self._count = RunService.Stepped:Connect(function(_, dt)
		if self._countdown > 0 then
			self._countdown -= dt
			self:_countChanged()

			-- Connect Countdown to UI
		else
			local _playersToStart = self.Players
			self:StopCount()
			self:Disable()

			GameService:requestMatch(_playersToStart)

			task.delay(5, function()
				self:Enable()
			end)
			--self:Reset()
		end
	end)

	self._maid:GiveTask(self._count)
end

function Area:StopCount()
	if not self._count then
		return
	end

	self._count:Disconnect()
	self._count = nil
	self._countdown = self.Countdown

	self:_countChanged()
end

-- We count manually incase any indexing issues come up.
function Area:GetHeadCount()
	local _headCount = 0

	for i, v in pairs(self.Players) do
		_headCount += 1
	end

	return _headCount
end

-- Checks if we can add another player to the round or not. If the game is full it won't add a new player.
-- Can also edit this so that we have more custom circumstances for letting a round happen or not.
--      (Check Rank of players etc)
function Area:CanAdd()
	local _headCount = self:GetHeadCount()

	if _headCount < self.Max then
		return true
	end

	return false
end

function Area:_listChanged()
	local RoundService = Knit.GetService("RoundService")
	local PlayerService = Knit.GetService("PlayerService")

	local playersToIterate = PlayerService:GetPlayersInLobby()

	for i, v in pairs(playersToIterate) do
		RoundService.Client.PlayerListChanged:Fire(v.Player, self.Object, self.Players)
	end
end

function Area:_countChanged()
	local RoundService = Knit.GetService("RoundService")
	local PlayerService = Knit.GetService("PlayerService")

	local playersToIterate = PlayerService:GetPlayersInLobby()

	for i, v in pairs(playersToIterate) do
		RoundService.Client.CountdownChanged:Fire(v.Player, self.Object, self._countdown)
	end
end

function Area:_add(player)
	self.Players[player.Player] = player
	self:_listChanged()
end

function Area:_remove(player)
	self.Players[player.Player] = nil
	self:_listChanged()
end

function Area:Check(player)
	if self._disabled then
		return
	end

	if player.Player then
		local character = player.Player.Character

		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local overlap = self:GetRegion()
				local isPlayerIn = overlap:Check(hrp) 

				if self:CanAdd() then
					if isPlayerIn then
						if not self.Players[player.Player] then
							self:_add(player)
							self:StartCount()
						end

						return true
					end
				end

				if not isPlayerIn and self.Players[player.Player] then
					self:_remove(player)

					local headCount = self:GetHeadCount()

					if headCount == 0 then
						self:StopCount()
					end
				end
			end
		end
	end
end

function Area:Create() end

function Area:Destroy()
	self._maid:DoCleaning()
end

return Area
