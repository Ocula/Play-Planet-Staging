-- [[ Tree Object Backend Handler ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)

local TreeHandler = {}
TreeHandler.__index = TreeHandler

function TreeHandler.new(element, tree, data)
	local Maid = require(Knit.Library.Maid)

	local self = setmetatable({
		Element = element,
		Tree = tree,
		_maid = Maid.new(),
	}, TreeHandler)

	-- Set data values
	for i, v in pairs(data) do
		self[i] = v
	end

	return self
end

function TreeHandler:Hide()
	self.Visible = false
	self.Element.props.Visible = false

	self:Update()
end

function TreeHandler:GetKey() -- For objects that have no quick index
	if not self._key then
		self._key = HttpService:GenerateGUID(false)
	end

	return self._key
end

function TreeHandler:Update()
	Roact.update(self.Tree, Roact.createElement(self.Element))
end

return TreeHandler
