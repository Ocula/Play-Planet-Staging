local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrUtility = require(Knit.Library.CmdrUtility)

local function check(context)
	return CmdrUtility:GetUserHasPermission(context)
end

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if RunService:isClient() then
			if not check(context) then
				return "You don't have permission to run this command"
			end
		end
	end)
end
