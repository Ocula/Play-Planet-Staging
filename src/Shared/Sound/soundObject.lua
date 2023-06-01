local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Library.Promise)
local SoundService = game:GetService("SoundService")

local soundObject = {}
soundObject.__index = soundObject

function soundObject.new(soundInfo)
	local _newSound = {
		SoundId = "rbxassetid://" .. soundInfo.SoundId,
		Start = soundInfo.Start or 0,
		End = soundInfo.End or nil,
		PlaybackSpeed = soundInfo.PlaybackSpeed or 1,
		Looped = soundInfo.Looped or false,

		__destroyOnComplete = true,
		__binParent = soundInfo.IndexParent,
	}

	-- Create object
	local obj = Instance.new("Sound")
	obj.SoundId = _newSound.SoundId
	obj.PlaybackSpeed = _newSound.PlaybackSpeed
	obj.Looped = _newSound.Looped
	obj.TimePosition = _newSound.Start

	-- Reparent to local sound position if need be.
	if not _newSound.__binParent then
		obj.Parent = game.Workspace
	end

	_newSound.Object = obj

	return setmetatable(_newSound, soundObject)
end

function soundObject:Play()
	if self.Start then
		self.Object.TimePosition = self.Start
	end

	if self.End then
		task.spawn(function()
			repeat
				task.wait(0.01)
			until self.Object.TimePosition >= self.End
			warn("Ended", self.Object.TimePosition, self.End)
			self.Object:Stop()
		end)
	end

	self.Object:Play()

	if self.__destroyOnComplete then
		self.Object.Ended:connect(function()
			self:Destroy()
		end)
	end
end

function soundObject:Destroy()
	if self.Object then
		self.Object:Destroy()
	end
end

return soundObject
