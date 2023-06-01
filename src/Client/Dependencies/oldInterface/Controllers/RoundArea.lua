--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)
local Maid = require(Knit.Library.Maid)
local Binder = require(Knit.Library.Binder)

local AreaComponent = require(Knit.Modules.Interface.Build.Components.AreaComponent)
local PlayerComponent = require(Knit.Modules.Interface.Build.Components.Player.PlayerComponent)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local RoundArea = {
	Interfaces = {},
	_maid = Maid.new(),
}

-- Test
--local AreaComponentRequired = require(Knit.Modules.Interface.Build.Components.AreaComponent)
RoundArea.__index = RoundArea

function RoundArea:GetElement()
	return self._element
end

function RoundArea.createComponent()
	return Roact.createElement(AreaComponent, {}, {})
end

local dt = os.time()

function RoundArea.Render()
	for instance, v in pairs(RoundArea.Interfaces) do
		local originVector = v.Origin
		local originalSize = v.Size

		local screenPoint, visible = workspace.CurrentCamera:WorldToScreenPoint(originVector)

		v.Element.props.Size =
			UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset)

		v.Element.props.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
		v.Element.props.Visible = visible

		-- Change Headcount / Countdown
		-- v.Element.props.Headcount = v.Headcount
		-- v.Element.props.Max = v.Max
		-- v.Element.props.Countdown = v.Countdown

		Roact.update(v.Tree, Roact.createElement(AreaComponent, v.Element.props)) -- THIS IS EXPENSIVE. HOW DO WE FIX IT.
	end
end

function RoundArea.new(object)
	local newArea = RoundArea.createComponent()

	-- Mount tree first
	local tree = Roact.mount(newArea, PlayerGui) -- Tree must be mounted before we can use our custom get bindings function.

	-- Now create our backend object.
	local TreeHandler = require(Knit.Modules.Interface.Modules.TreeHandler)

	local data = object:GetAttributes()
	data.Origin = object.Position + Vector3.new(0, object.Size.Y / 2, 0)
	data.Object = object
	data.PlayerList = {}

	local currentSize = newArea.props.Size

	newArea.props.Size = UDim2.new(
		currentSize.X.Scale * data.Max,
		currentSize.X.Offset * data.Max,
		currentSize.Y.Scale,
		currentSize.Y.Offset
	) -- Resize our window to fit the max amount of players.

	newArea.props.Max = data.Max
	newArea.props.TimerMax = data.Countdown

	-- Original Values
	for i, v in pairs(newArea.props) do
		data[i] = v
	end

	local newInterface = TreeHandler.new(newArea, tree, data)

	return newInterface
end

function RoundArea.Count(table)
	local _count = 0

	for i, v in pairs(table) do
		_count += 1
	end

	return _count
end

function RoundArea:Halt()
	self._maid:DoCleaning()

	for _, interface in pairs(self.Interfaces) do
		interface:Hide()
	end
end

function RoundArea:Start()
	-- Start render loop here
	self._maid:GiveTask(RunService.RenderStepped:Connect(self.Render))
end

function RoundArea:Init()
	-- Start looping?
	-- Listen to Binder
	local RoundAreaBinder = Binder.new("RoundArea", self.new)

	RoundAreaBinder:GetClassAddedSignal():Connect(function(class)
		if class._ShellClass then
			return
		end

		if not self.Interfaces[class.Object] then
			self.Interfaces[class.Object] = class
		end
	end)

	RoundAreaBinder:Start()

	--  Listen for players
	local function createPlayerElement(player)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
		}, {
			Player = Roact.createElement(PlayerComponent, {
				playerImage = player.Image or "rbxassetid://",
				score = player.Score or 0,
			}),
		})
	end

	local RoundService = Knit.GetService("RoundService")

	RoundService.CountdownChanged:Connect(function(object, count)
		local element = self.Interfaces[object]

		if element then
			if count then
				element.Element.props.Countdown = count
			else
				element.Element.props.Countdown = element.Element.props.TimerMax
			end
		end
	end)

	RoundService.PlayerListChanged:Connect(function(object, list)
		local element = self.Interfaces[object]

		if element then
			local _newList = {}

			for i, v in pairs(list) do
				_newList[i] = createPlayerElement(v)
			end

			element.Element.props.Headcount = self.Count(_newList)
			element.Element.props.PlayerList = _newList
		end
	end)

	RoundService.PlayerLobbyStatusChanged:Connect(function(_inLobby)
		if not _inLobby then
			self:Halt()
		else
			self:Start()
		end
	end)

	--	table.insert(RoundArea.Interfaces, newInterface)
end

return RoundArea
