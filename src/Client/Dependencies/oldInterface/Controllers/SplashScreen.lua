-- Build and provide functions for game's boot Splash Screen
local Splash = {}
Splash.__Index = Splash

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(Knit.Library.Roact)
local Otter = require(Knit.Modules.Interface.Utility.Otter)
local Sound = require(Knit.Library.Sound)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

Splash.motors = {}
Splash.bin = {}

function Splash:createComponent()
	self.splashScreen = require(Knit.Modules.Interface.Build.Components.Splash)
end

function Splash:toggleDoors(bool) -- Open / Closed (True / False)
	local left, right = 0.4, 0.6

	if not bool then
		left = 0.5
		right = 0.5
	end

	self.splashScreen:setDoorGoals(left, right, {
		dampingRatio = 0.35,
		frequency = 4,
	})
end

function Splash:shake(vel, sound) -- Parameters: vel - Velocity
	if sound then
		local sound = Sound.getSound(sound)
		sound:Play()
	end

	self.splashScreen:shake(vel)
end

function Splash:load(percent, options) -- Set Loading bar and shake effect to Loading percentage.
	-- Get motor
	local _motor = self.motors.loadBar

	if not _motor then
		_motor = Otter.createSingleMotor(0.05)
		self.motors.loadBar = _motor

		_motor:onStep(function(value)
			self.splashScreen:setLoadPercentage(value)
			self.bin.currentPercentage = value
		end)
	end

	_motor:setGoal(Otter.spring(percent, options or {}))
end

function Splash:unmount()
	-- Exit effect
	self.splashScreen:hide()
	Roact.unmount(self.splashTree)
end

function Splash:mount()
	if not self.splashScreen then
		self:createComponent()
	end

	self.splashMount = Roact.createElement(self.splashScreen)

	self.splashTree = Roact.mount(self.splashMount, PlayerGui)
end

return Splash
