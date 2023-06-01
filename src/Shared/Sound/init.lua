local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local gameSoundService = game:GetService("SoundService")
local bin = gameSoundService:WaitForChild("Game")

local Object = require(script.soundObject)

local Sound = {
	_bin = {},
}

Sound.__Index = Sound

function Sound.getSound(id)
	--warn("Sound:", id)
	local _asset = AssetLibrary.get(id)
	return Sound.new(_asset)
end

function Sound.new(...) -- Sound.new(SoundInfo) --> Returns a sound object, Reference soundObject.lua for API details.
	return Object.new(...)
end

function Sound.play() end

return Sound
