-- Handles the relationship between the Interface and Components.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local ComponentHandler = {}
ComponentHandler.__index = ComponentHandler

function ComponentHandler.getTo(tree, parentString) -- parentString for debugging
	local _object = script.Components

	local function checkTree(thisTree)
		for index, nextName in pairs(thisTree) do
			_object = _object:FindFirstChild(nextName)

			if not _object and nextName then
				_object = script.Themes
				checkTree(tree)
				break
			end
		end
	end

	checkTree(tree)

	if not _object then
		error("ComponentHandler failed to find the desired instance in the tree:", parentString)
	end

	return _object
end

function ComponentHandler:Get(treeQuery)
	local tree = Utility.splitString(treeQuery, "/")
	local component = self.getTo(tree, treeQuery)

	return require(component)
end

return ComponentHandler
