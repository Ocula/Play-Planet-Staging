local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Maid = require(Shared:WaitForChild("Maid")) 
local Signal = require(Shared:WaitForChild("Signal"))

-- CONSTANTS

local SPEED = {
	[Enum.HumanoidStateType.Running] = true,
}

local IN_AIR = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true
}

local REMAP = {
	["onFreefall"] = "onFreeFall",
}

--#TODO: remove freefall state (disguise as jumping state)

-- Class

local StateTrackerClass = {}
StateTrackerClass.__index = StateTrackerClass
StateTrackerClass.ClassName = "StateTracker"

-- Public Constructors

function StateTrackerClass.new(controller)
	local self = setmetatable({}, StateTrackerClass)
	local characterAnimate = require(Packages:WaitForChild("character-animate")) 

	local player = game.Players.LocalPlayer

	if not player.Character then repeat task.wait() until player.Character end 

	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid") 

	self._maid = Maid.new()

	self.Controller = controller
	self.State = Enum.HumanoidStateType.Running
	self.Speed = 0

	self.Jumped = false
	self.JumpTick = os.clock()

	--self.Animation = require(controller.Character:WaitForChild("Animate"):WaitForChild("Controller"))
	self.Changed = Signal.new()
	self.Animate = characterAnimate.animateManually(script, humanoid) 

	init(self)

	return self
end

-- Private Methods

function init(self)
	self._maid:GiveTask(self.Changed)
	self._maid:GiveTask(self.Changed:Connect(function(state, speed)
		self.Animate.fireState(state, speed)
	end))
end

-- Public Methods

function StateTrackerClass:Update(gravityUp, isGrounded, isInputMoving)
	local cVelocity = self.Controller.HRP.Velocity
	local gVelocity = cVelocity:Dot(gravityUp)

	local oldState = self.State
	local oldSpeed = self.Speed

	local newState = nil
	local newSpeed = cVelocity.Magnitude

	if not isGrounded then
		if gVelocity > 0 then
			if self.Jumped and not self._isJumping then
				newState = Enum.HumanoidStateType.Jumping

				self._isJumping = true 
			else 
				--newState = Enum.HumanoidStateType.Freefall
			end
		else
			if self.Jumped then
				self.Jumped = false
			end
			--newState = Enum.HumanoidStateType.Freefall
		end
	else
		if self.Jumped and os.clock() - self.JumpTick > 0.1 then
			self.Jumped = false
			self._isJumping = false 
		end
		newSpeed = (cVelocity - gVelocity*gravityUp).Magnitude
		newState = Enum.HumanoidStateType.Running
	end--]]

	newSpeed = isInputMoving and newSpeed or 0

	if oldState ~= newState or (SPEED[newState] and math.abs(newSpeed - oldSpeed) > 0.1) then
		self.State = newState
		self.Speed = newSpeed
		self.Changed:Fire(newState, newSpeed)
	end
end

function StateTrackerClass:RequestJump()
	if not self.Jumped then 
		self.Jumped = true
		self.JumpTick = os.clock()
		return true
	end 

	return false
end

function StateTrackerClass:Destroy()
	self._maid:DoCleaning()
end

return StateTrackerClass