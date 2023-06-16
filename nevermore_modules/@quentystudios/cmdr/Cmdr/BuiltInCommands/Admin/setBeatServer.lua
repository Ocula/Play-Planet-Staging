local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, players, id, beat)
    local SoundService = Knit.GetService("SoundService") 

	for _, player in pairs(players) do
        SoundService.Client.SkipSound:Fire(player, id, beat)
	end
	return ("Set %d players"):format(#players)
end
