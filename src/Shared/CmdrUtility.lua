local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrUtility = {}
CmdrUtility.__index = CmdrUtility

CmdrUtility.Users = {
	[9466529] = true,
	[5507877] = true,
}

function CmdrUtility:GetUserHasPermission(context)
	local user = context.Executor
	return CmdrUtility.Users[user.UserId]
end

return CmdrUtility
