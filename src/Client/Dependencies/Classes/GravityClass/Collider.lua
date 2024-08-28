local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Library.Signal)
local Maid = require(Shared:WaitForChild("Maid"))

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Whitelist

local params2 = RaycastParams.new()
params2.FilterType = Enum.RaycastFilterType.Blacklist

-- Class

local ColliderClass = {}
ColliderClass.__index = ColliderClass
ColliderClass.ClassName = "Collider"

-- Public Constructors

function ColliderClass.new(controller)
	local self = setmetatable({
		OnGrounded = Signal.new(), 
		_isGrounded = false, 
	}, ColliderClass)

	self:Create(controller)

	self._maid = Maid.new()
	
	self.Controller = controller

	init(self)

	return self
end

-- Private Methods

local function getHipHeight(controller)
	if controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return controller.Humanoid.HipHeight + 0.05
	end
	return 2
end

local function getAttachment(controller)
	if controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return controller.HRP:WaitForChild("RootRigAttachment")
	end

	return controller.HRP:WaitForChild("RootAttachment")
end

function ColliderClass:Create(controller)
	--local attach = getAttachment(controller)
	local GravityService = Knit.GetService("GravityService") 
	local isLoaded = Signal.new() 
	
	warn("Controller:", controller)

	GravityService:GetCollider():andThen(function(Collider) 
		local Model = Collider.Object 
		self.Model = Model 

		local Sphere = Collider.Sphere
		self.Sphere = Sphere 

		local FloorDetector = Collider.FloorDetector
		self.FloorDetector = FloorDetector

		local JumpDetector = Collider.JumpDetector 
		self.JumpDetector = JumpDetector

		local sphereAttach = Instance.new("Attachment")
		sphereAttach.Parent = Sphere

		Sphere.CFrame = controller.SpawnPoint

		local WalkForce			= Collider.WalkForce 
		local GForce 			= Collider.GForce
		local GyroAttachment0 	= Collider.GyroAttachment0
		local Gyro 				= Collider.Gyro 

		local Camera = workspace.CurrentCamera
		
		Camera.CameraSubject = Sphere

		self.Sphere = Sphere
		self.WalkForce = WalkForce
		self.GForce = GForce 
		self.FloorDetector = FloorDetector
		self.JumpDetector = JumpDetector
		self.Gyro = Gyro  
		self.GyroAtt0 = GyroAttachment0 

		isLoaded:Fire() 
	end)

	isLoaded:Wait() 

	warn("Collider loaded!") 
end

function init(self)
	self._maid:GiveTask(self.Model)
	self._maid:GiveTask(self.WalkForce)
	self._maid:GiveTask(self.GForce)
	self._maid:GiveTask(self.FloorDetector)
	self._maid:GiveTask(self.Gyro)
	self._maid:GiveTask(self.GyroAtt0)
end

--[[

game:GetService("RunService").Stepped:Connect(function() 
	local ori1 = game.Selection:Get()[1].Orientation 
	local ori2 = game.Selection:Get()[2].Orientation  
	if ori1 ~= ori2 then 
		print(ori1, ori2) 
		print(ori2 - ori1) 
	end 
end)

]]

-- Public Methods

function ColliderClass:Update(force, gForce, cframe)
	self.WalkForce.Force = force
	self.GForce.Force = gForce 
	self.Gyro.CFrame = cframe

	--print("Output", self.Gyro.CFrame)
end

function ColliderClass:GetGround()
	local groundCheck = workspace:Raycast(self.Sphere.Position, self.Controller._gravityUp * -3, params2) 

	if groundCheck then 
		return groundCheck.Instance, groundCheck 
	end 
end 

-- Check in front of us 
function ColliderClass:GetSlope()
	local checkDirection = self.Sphere.CFrame * CFrame.new(0, -3, 3) 
	local direction = (checkDirection.Position - self.Sphere.Position).Unit 
	local slopeCheck = workspace:Shapecast(self.Sphere, direction * 6, param2)

	if slopeCheck then 
		return slopeCheck.Instance, slopeCheck
	end 
end 

function ColliderClass:IsGrounded(isJumpCheck)
	local parts = (isJumpCheck and self.JumpDetector or self.FloorDetector):GetTouchingParts()
	for _, part in pairs(parts) do
		if not part:IsDescendantOf(self.Controller.Character) and (part.CanCollide) then
			if self._isGrounded ~= true then 
				self.OnGrounded:Fire(true) 
				self._isGrounded = true 
			end 

			return true
		end
	end

	if self._isGrounded == true then 
		self.OnGrounded:Fire(false) 
		self._isGrounded = false 
	end
end

function ColliderClass:GetStandingPart()
	params2.FilterDescendantsInstances = {self.Controller.Character}

	local gravityUp = self.Controller._gravityUp
	local result = workspace:Raycast(self.Sphere.Position, -1.1*gravityUp, params2)

	return result and result.Instance
end

function ColliderClass:Destroy()
	self._maid:DoCleaning()
end


return ColliderClass