local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrController = Knit.CreateController({ Name = "CmdrController" })

function CmdrController:KnitStart()
	local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

	-- Configurable, and you can choose multiple keys
	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end

function CmdrController:KnitInit() end

return CmdrController
