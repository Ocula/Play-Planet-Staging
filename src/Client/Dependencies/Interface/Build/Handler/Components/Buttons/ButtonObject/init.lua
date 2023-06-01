local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal)
local Handler = require(Knit.Modules.Interface.get)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

local Button = {}
Button.__index = Button

function Button.new(buttonType, props, callback)
	if not buttonType then
		error("Button has no specified type.")
	end

	local _renderCheck, _render = script:FindFirstChild(buttonType .. "ButtonRender")

	if _renderCheck then
		_render = require(_renderCheck)
	end

	local self = setmetatable({
		_type = buttonType,
		_maid = Maid.new(),
		_signal = Signal.new(),
		_active = false,
		_render = _render,

		props = props,
	}, Button)

	self.props.Signal = Signal.new()
	self.props.Signal:Connect(callback)

	self._maid:GiveTask(self.props.Signal)

	local buttonObject = Handler:Get("Buttons/" .. buttonType .. "Button")(self.props)
	self._object = buttonObject

	-- Place into interface radar
	local Interface = Knit.GetController("Interface")
	Interface:AddButton(self)

	return self
end

function Button:Render()
	if not self._active then
		return
	end

	if not self._render then
		warn("Render being called on a button that has no render callback.")
	end

	self._render(self)
end

function Button:Animate()
	assert(self._type == "Textured" or self._type == "Popping", "Not a valid button type for animation.")
	self._active = true
end

function Button:Pause()
	self._active = false
end

function Button:Hide()
	self.props.Transparency:set(1) -- We can handle whether or not this is animated or not on the actual buttons itself.
	self:Destroy()
end

function Button:Destroy()
	local Interface = Knit.GetController("Interface")
	Interface:RemoveButton(self)

	self._maid:DoCleaning()
end

return Button
