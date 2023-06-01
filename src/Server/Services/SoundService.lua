local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SService = game:GetService("SoundService")
local Utility = require(Knit.Library.Utility)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local SoundService = Knit.CreateService({
	Name = "SoundService",
	Client = {},
})

function SoundService:Play(soundId)
	-- Plays this sound on the server.
	-- Creates and maintains this sound in the SoundService bins.
	-- Useful for having music that is replicated properly to all players. Specifically with game-reliant sound effects.
end

function SoundService:KnitStart()
	-- Create master bin
	local _bin = Utility.createFolder("Game", SService)
	_bin:SetAttribute("MasterVolume", 0.5)

	-- Setup Bins
	for name, _ in pairs(AssetLibrary.Assets.Audio.Game) do
		Utility.createFolder(name, _bin) -- Parent it to our master bin.
	end
end

function SoundService:KnitInit() end

return SoundService
