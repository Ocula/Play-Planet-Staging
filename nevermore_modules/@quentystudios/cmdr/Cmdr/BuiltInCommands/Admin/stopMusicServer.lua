local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, players, id)
    local SoundService = Knit.GetService("SoundService") 

	for _, player in pairs(players) do
        SoundService.Client.StopSound:Fire(player, id)
	end

	return ("Set %d players"):format(#players)
end
