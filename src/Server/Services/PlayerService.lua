-- @Ocula
-- December 30, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Players = {},
	Client = {
		PlayerLoaded = Knit.CreateSignal(),
	},
})

-- Dependencies
local Utility = require(Knit.Library.Utility)
local Player = require(Knit.Modules.Player)
local Profile = {
	Profiles = {},
	Key = "KNOCKOFF_TESTING",
	Service = require(Knit.Modules.Profile),
	Blank = require(Knit.Modules.Profile.Blank),
}

function PlayerService:GetPlayersInLobby()
	local playersToReturn = Utility:FilterTable(self.Players, function(player)
		return player.Lobby
	end)

	return playersToReturn
end

function PlayerService.getProfile(user)
	return Profile.Profiles[user]
end

function PlayerService:new(newPlayer)
	local userId = newPlayer.UserId

	-- Handle profiling
	local loadedProfile = Profile.Store:LoadProfileAsync(Profile.Key .. userId, "ForceLoad")

	if loadedProfile then
		loadedProfile:Reconcile()

		loadedProfile:ListenToRelease(function()
			Profile.Profiles[newPlayer] = nil
			newPlayer:Kick(
				"Your account did not load into the game properly. To save your data, you have been kicked. Please rejoin at your earliest convenience!"
			)
		end)

		Profile.Profiles[newPlayer] = loadedProfile

		-- Handle player only if profile is loaded.
		local playerObject = Player.new(newPlayer, loadedProfile)

		playerObject:Spawn()

		self.Players[newPlayer] = playerObject
		self.Client.PlayerLoaded:Fire(newPlayer, true)
	end
end

function PlayerService:KnitStart()
	local Players = game:GetService("Players")

	for _, player in pairs(Players:GetPlayers()) do
		self:new(player)
	end

	Players.PlayerAdded:Connect(function(p)
		self:new(p)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local playerObject = self.Players[player]
		playerObject.Leaving:Fire()
	end)
end

function PlayerService:KnitInit()
	Profile.Store = Profile.Service.GetProfileStore(Profile.Key, Profile.Blank)
end

return PlayerService
