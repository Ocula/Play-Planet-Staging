local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Library.Signal)

local GameController = Knit.CreateController({
	Name = "GameController",
	__loaded = false,
	__began = os.time(),

	Loaded = Signal.new(),
})

function GameController:getClientBegan()
	return self.__began
end

function GameController:KnitStart() end

function GameController:KnitInit()
	-- Connect Events
	local PlayerService = Knit.GetService("PlayerService")

	PlayerService.PlayerLoaded:Connect(function(bool)
		self.__loaded = bool
		self.Loaded:Fire(bool)
	end)
end

return GameController
