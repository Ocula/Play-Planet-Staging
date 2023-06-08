-- Spawn
-- @ocula
-- July 5, 2021

--[[

	Handling the logic and interaction of in-game Spawns

]]
local Spawn = {}
Spawn.__index = Spawn

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

function Spawn.new(_obj)
	if not _obj:FindFirstAncestor("Workspace") then
		--warn("Not a member of workspace.")
		return { _ShellClass = true, Destroy = function() end, Create = function() end }
	end

	local _data = _obj:GetAttributes()

	-- Create new table based on data.

	local _newData = {
		_busy = false,
	}

	for index, value in pairs(_data) do
		_newData[index] = value
	end

	_newData.Object = _obj

	return setmetatable(_newData, Spawn)
end

function Spawn:Create()
	warn("Create Called on Spawn")
end

function Spawn:Destroy()
	Knit.GetService("SpawnService").Spawns[self.Object] = nil
	game:GetService("CollectionService"):RemoveTag(self.Object, "Spawn")

	for i, v in pairs(self.Services.GameService.Players) do
		if v._activeSpawn and v._activeSpawn.Object == self.Object then
			v._activeSpawn = nil
		end
	end

	if self.Object then
		self.Object:Destroy()
	end
end

function Spawn:isBusy()
	return self._busy
end

function Spawn:Teleport(_player, _radius)
	if self._busy then
		warn("Spawn is busy, rerouting")
		return false
	end

	self._busy = true

	Utility:TeleportPlayer(_player.Player, self.Object.CFrame, _radius)

	-- Hold player here for a second to double check SetState

	if self.SetState then -- This spawn is in a different Gravity place. 
		local GravityService = Knit.GetService("GravityService") 
		GravityService.Client.SetState:Fire(_player, self.SetState) 
	end

	if self.HoldPlayer then
		local duration = self.Forcefield or self.HoldDuration

		local alignPos = Utility:HoldPlayer(_player.Player, self.Object.Position)

		if duration then
			task.delay(duration, function()
				alignPos:Destroy()
				self._busy = false
			end)
		end
	else
		self._busy = false
	end

	return true
	--self._busy = false
end

return Spawn
