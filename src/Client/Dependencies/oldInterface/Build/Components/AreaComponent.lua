local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies
local Roact = require(Knit.Library.Roact)

local AreaComponent = Roact.Component:extend("AreaComponent")

function AreaComponent:init()
	self.props.Size = UDim2.new(0.05, 0, 0.1, 0) -- Show 8 players, it will multiply x by Player amount.
	self.props.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.props.Visible = false
	self.props.Countdown = 10
	self.props.TimerMax = 10
	self.props.Headcount = 0
	self.props.Max = 4
	self.props.PlayerList = {}
end

function AreaComponent:render()
	-- Render our Area component UI.
	local size, position, visible = self.props.Size, self.props.Position, self.props.Visible
	local timer, timerMax = self.props.Countdown, self.props.TimerMax
	local headcount = tostring(self.props.Headcount) .. "/" .. tostring(self.props.Max)

	local timerVisible = false

	if timer < timerMax then
		timerVisible = true
	end

	return Roact.createElement("ScreenGui", {
		Name = "MatchArea",
		ResetOnSpawn = false,
	}, {
		Frame = Roact.createElement("Frame", {
			Size = size,
			Position = position,
			Visible = visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
		}, {
			TimerFrame = Roact.createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.2, 0),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, -0.8, 0),
				BackgroundTransparency = 1,
				Visible = timerVisible,
			}, {
				TimerText = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					Text = tostring(timer):sub(1, 4) .. "s",
					FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
					TextColor3 = Color3.new(1, 0.345098, 0.345098),
					BackgroundTransparency = 1,
					TextSize = 24,
				}),
			}),
			HeadcountFrame = Roact.createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.2, 0),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, -0.2, 0),
				BackgroundTransparency = 1,
			}, {
				CountFrame = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					Text = headcount,
					FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
					TextColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					TextSize = 24,
				}),
			}),
			Container = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = "Horizontal",
					HorizontalAlignment = "Center",
				}),
				Players = Roact.createFragment(self.props.PlayerList),
			}),
		}),
	})
end

return AreaComponent -- Bindings will not have been loaded until :init() is called.
