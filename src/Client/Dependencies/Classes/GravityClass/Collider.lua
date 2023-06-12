local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Maid = require(Shared:WaitForChild("Maid"))

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Whitelist

local params2 = RaycastParams.new()
params2.FilterType = Enum.RaycastFilterType.Blacklist

-- CONSTANTS

local CUSTOM_PHYSICAL = PhysicalProperties.new (0.7, 0, 0, 1, 100)

-- Class

local ColliderClass = {}
ColliderClass.__index = ColliderClass
ColliderClass.ClassName = "Collider"

-- Public Constructors

function ColliderClass.new(controller)
	local self = setmetatable({}, ColliderClass)

	self.Model = Instance.new("Model")

	local sphere, vForce, floor, floor2, gyro, gyroatt0, gyroatt1 = create(self, controller)

	self._maid = Maid.new()
	
	self.Controller = controller

	self.Sphere = sphere
	self.VForce = vForce
	self.FloorDetector = floor
	self.JumpDetector = floor2
	self.Gyro = gyro 

	self.GyroAtt0 = gyroatt0 
	self.GyroAtt1 = gyroatt1 

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

local function getAttachement(controller)
	if controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return controller.HRP:WaitForChild("RootRigAttachment")
	end
	return controller.HRP:WaitForChild("RootAttachment")
end

function create(self, controller)
	local hipHeight = getHipHeight(controller)
	local attach = getAttachement(controller)

	local sphere = Instance.new("Part")
	sphere.Name = "Sphere"
	sphere.Massless = true
	sphere.Size = Vector3.new(2, 2, 2)
	sphere.Shape = Enum.PartType.Ball
	sphere.Transparency = 1
	sphere.CustomPhysicalProperties = CUSTOM_PHYSICAL

	local floor = Instance.new("Part")
	floor.Name = "FloorDectector"
	floor.CanCollide = false
	floor.Massless = true
	floor.Size = Vector3.new(2, 1, 1)
	floor.Transparency = 1

	local floor2 = Instance.new("Part")
	floor2.Name = "JumpDectector"
	floor2.CanCollide = false
	floor2.Massless = true
	floor2.Size = Vector3.new(2, 0.2, 1)
	floor2.Transparency = 1

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight, 0.1)
	weld.Part0 = controller.HRP
	weld.Part1 = sphere
	weld.Parent = sphere

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight - 1.5, 0)
	weld.Part0 = controller.HRP
	weld.Part1 = floor
	weld.Parent = floor

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight - 1.1, 0)
	weld.Part0 = controller.HRP
	weld.Part1 = floor2
	weld.Parent = floor2

	local vForce = Instance.new("VectorForce")
	vForce.Force = Vector3.new(0, 0, 0)
	vForce.ApplyAtCenterOfMass = true
	vForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vForce.Attachment0 = attach
	vForce.Parent = controller.HRP

	local attachmentBlock = Instance.new("Part")
	attachmentBlock.Parent = workspace.game.bin.client 
	attachmentBlock.Transparency = 1
	attachmentBlock.CanCollide = false 
	attachmentBlock.Anchored = true
	attachmentBlock.Name = "AttachmentBlock"
	attachmentBlock.CanQuery = false 
	attachmentBlock.Size = Vector3.new(1,1,1) 

	local gyroAttachment0 = Instance.new("Attachment") 
	gyroAttachment0.Parent = controller.HRP 
	gyroAttachment0.Name = "Align"

	local gyroAttachment1 = Instance.new("Attachment") 
	gyroAttachment1.Parent = attachmentBlock 
	gyroAttachment1.Name = "Align2"

	local gyro = Instance.new("AlignOrientation")
	gyro.Parent = controller.HRP 
	gyro.Attachment0 = gyroAttachment0
	gyro.Attachment1 = gyroAttachment1
	gyro.RigidityEnabled = true 

	--[[
	gyro.P = 25000
	gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	gyro.CFrame = controller.HRP.CFrame
	gyro.Parent = controller.HRP--]]

	floor.Touched:Connect(function() end)
	floor2.Touched:Connect(function() end)

	sphere.Parent = self.Model
	floor.Parent = self.Model
	floor2.Parent = self.Model

	return sphere, vForce, floor, floor2, gyro, gyroAttachment0, gyroAttachment1
end

function init(self)
	self._maid:GiveTask(self.Model)
	self._maid:GiveTask(self.VForce)
	self._maid:GiveTask(self.FloorDetector)
	self._maid:GiveTask(self.Gyro)
	self._maid:GiveTask(self.GyroAtt0)
	self._maid:GiveTask(self.GyroAtt1) 

	self.Model.Name = "Collider"
	self.Model.Parent = self.Controller.Character
end

-- Public Methods

function ColliderClass:Update(force, cframe)
	local x,y,z = cframe:ToOrientation() 
	local orientation = Vector3.new(math.deg(x), math.deg(y), math.deg(z)) 

	self.VForce.Force = force
	self.GyroAtt1.Orientation = orientation 
end

function ColliderClass:IsGrounded(isJumpCheck)
	local parts = (isJumpCheck and self.JumpDetector or self.FloorDetector):GetTouchingParts()
	for _, part in pairs(parts) do
		if not part:IsDescendantOf(self.Controller.Character) and (part.CanCollide) then
			return true
		end
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