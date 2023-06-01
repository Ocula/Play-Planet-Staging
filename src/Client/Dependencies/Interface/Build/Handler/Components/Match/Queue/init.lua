-- Match UI handler. Creates all Match interfaces in-game and in-lobby.
--  Queue -> MatchQueue in Lobby Areas. Handles the SurfaceGUIs for those.
--  GameHUD -> In-game UI

--[=[ 
    API:
        Match.new(component) --> string: either Queue / GameHUD right now
            Passes back a component for any child of Match.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Handler = require(Knit.Modules.Interface.get)

local MatchQueue = Handler:Get("Match/Queue/MatchQueue")
local MatchSurface = Handler:Get("Match/Queue/MatchSurfaceUI")

local Queue = {}
Queue.__index = Queue

function Queue.new(adornee)
	local self = setmetatable({}, Queue)

	self.props = {
		Adornee = adornee,
	}

	self._object = MatchQueue.new(self.props)

	return self
end

return Queue
