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

local Queue = Handler:Get("Match/Queue")
local GameHUD = Handler:Get("Match/GameHUD")

local Match = {
	_Queue = Queue,
	_GameHUD = GameHUD,
}

Match.__index = Match

function Match.new(component)
	local module = Match[component]

	if not module then
		module = Handler:Get("Match/" .. component) -->
	end

	return module.new()
end

return Match
