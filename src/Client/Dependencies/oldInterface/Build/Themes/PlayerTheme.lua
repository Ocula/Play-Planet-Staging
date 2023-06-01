local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)

local PlayerContext = Roact.createContext({})

return PlayerContext
