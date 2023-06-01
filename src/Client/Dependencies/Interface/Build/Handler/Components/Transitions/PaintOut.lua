--[[
    Paints the entire screen with whatever color you want.


        customWait += 1

        if customWait >= 2 then 
            task.wait(.01) 
            customWait = 0 
        end

    local Fusion = require(game.ReplicatedStorage:FindFirstChild("Fusion", true))
    local Spring = Fusion.Spring

            local image = Instance.new("ImageLabel", frame)
        image.Size = UDim2.new(1,0,1,0)
        image.Image = "rbxassetid://12157072067"
        image.BackgroundTransparency = 1
        image.ImageColor3 = Color3.new(0.3,1,1)

            local uicorn = Instance.new("UICorner", frame)
        uicorn.CornerRadius = UDim.new(1,0) 

    game.StarterGui.TestContainer.Container:ClearAllChildren()

    local function createTestPoint(newPos, lastPos)
        local currentPos = lastPos:Lerp(newPos, 0.5)
        local diff = (newPos - lastPos)
        local mag = .3
        local angle = math.atan2(diff.Y, diff.X) 
        local size = UDim2.new(mag,0,mag,0)
        local rotation = math.deg(angle)

        local pos = UDim2.new(currentPos.X,0,currentPos.Y,0)
        local lastPos = UDim2.new(lastPos.X,0,lastPos.Y,0)
        local frame = Instance.new("Frame", game.StarterGui.TestContainer.Container)

        frame.Size = size
        frame.SizeConstraint = Enum.SizeConstraint.RelativeXX
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.BackgroundColor3 = Color3.new(0.3, 1, 1)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 0
        frame.Position = lastPos
        frame.Rotation = rotation 

        task.spawn(function()
            frame:TweenPosition(pos, "Out", "Quad", .1, true)
            frame:TweenSize(UDim2.new(1.2,0,1.2,0), "Out", "Quad", 1, true)

            task.delay(3, function()
                frame:TweenSize(UDim2.new(0,0,0,0), "In", "Quad", .1, false)
            end)
        end)

        local uicorn = Instance.new("UICorner", frame)
        uicorn.CornerRadius = UDim.new(1,0) 
    end

    local customWait = 0 
    local LastPosition = Vector2.new(0,0) 

    local countTo = 10
    local countFrom = -2
    local increment = 0.3

    local amplify = 0.8

    for i = countFrom,countTo,increment do 
        local Container = game.StarterGui.TestContainer.Container

        local calcX = ((math.sin(i*amplify)))
        local calcY = 0.5 + calcX

        local newPosition = Vector2.new(i/(countTo-2), calcY)

        createTestPoint(newPosition, LastPosition)

        LastPosition = newPosition

        task.wait()
        customWait += 1
    end 

    print("Last point created") 
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Maid = require(Knit.Library.Maid)
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

local PaintOut = {}
PaintOut.__index = PaintOut

function PaintOut.new(props)
	if not props then
		props = {}
	end

	local self = setmetatable({
		countTo = 10,
		countFrom = -2,
		increment = 0.3,
		amplify = 0.8,

		Color = props.Color or Color3.new(0, 0.866666, 1),

		Paint = {},
		_maid = Maid.new(),
	}, PaintOut)

	self:createBin()

	return self
end

function PaintOut:createPaintFrame(newPos, lastPos)
	local _lastPos = State(UDim2.new(lastPos.X, 0, lastPos.Y, 0))
	local size = State(UDim2.new(0.3, 0, 0.3, 0))

	local paintFrame = {
		SpringSettings = {
			Speed = State(20),
			DampingRatio = State(1),
		},
		Object = nil,
		Size = size,
		Position = _lastPos,
	}

	paintFrame.Object = New("Frame")({
		Parent = self.BinFrame,
		Position = Spring(
			_lastPos,
			paintFrame.SpringSettings.Speed:get(),
			paintFrame.SpringSettings.DampingRatio:get()
		),
		Size = Spring(size, paintFrame.SpringSettings.Speed:get(), paintFrame.SpringSettings.DampingRatio:get()),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = self.Color,

		[Children] = {
			UICorn = New("UICorner")({
				CornerRadius = UDim.new(1, 0),
			}),
		},
	})

	_lastPos:set(UDim2.new(newPos.X, 0, newPos.Y, 0))
	size:set(UDim2.new(1, 0, 1, 0))

	self._maid:GiveTask(paintFrame.Object)

	return paintFrame
end

function PaintOut:createBin()
	local _playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local _bin = _playerGui:WaitForChild("Transitions")

	self.BinFrame = New("Frame")({
		Parent = _bin,
		Name = "PaintContainer",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Rotation = 30,
	})

	self._maid:GiveTask(self.BinFrame)
end

function PaintOut:In()
	if not self.BinFrame then
		self:createBin()
	end

	local countFrom, countTo, increment, amplify = self.countFrom, self.countTo, self.increment, self.amplify
	local lastPosition = Vector2.new(0, 0)

	local paintIndex = 1

	for i = countFrom, countTo, increment do
		local calcX = (math.sin(i * amplify))
		local calcY = 0.5 + calcX

		local newPosition = Vector2.new(i / (countTo - 2), calcY)

		local _object = self:createPaintFrame(newPosition, lastPosition)

		table.insert(self.Paint, paintIndex, _object)

		lastPosition = newPosition

		task.wait()

		paintIndex += 1
	end
end

function PaintOut:Out()
	for _, v in pairs(self.Paint) do
		v.Object:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1, false)
		task.wait()
	end

	task.delay(2, function()
		self:Destroy()
	end)
end

function PaintOut:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self._maid:DoCleaning()
end

return PaintOut
