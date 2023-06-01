local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)

local ComponentHandler = {}
ComponentHandler.__index = ComponentHandler

function ComponentHandler.new(component)
	local newElement = Roact.createElement(component)
end

function ComponentHandler:Hide() end

return ComponentHandler
