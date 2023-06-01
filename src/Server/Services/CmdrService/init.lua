local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrService = Knit.CreateService({
	Name = "CmdrService",
	Client = {},
})

function CmdrService:KnitStart()
	local Cmdr = require(Knit.Library.Cmdr)

	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterHooksIn(script.Hooks)
end

function CmdrService:KnitInit() end

return CmdrService
