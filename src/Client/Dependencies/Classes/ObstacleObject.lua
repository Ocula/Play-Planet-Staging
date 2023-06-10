-- Obstacle Object
-- Username
-- December 24, 2020

--Roblox service dependencies
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ObstacleObject = {}
ObstacleObject.__index = ObstacleObject

local Base_Time = 3
local Base_CF = CFrame.new()

local Utility, Thread 

--- // Utility Functions

function CompileValues(Folder)
	local _compile = {};

	for i,v in pairs(Folder:GetChildren()) do
		if v["Value"] then 
			_compile[v.Name] = v.Value 
		end
	end
	
	return _compile
end

function CompileVectors(Folder)
	if not Folder then return {} end
	
	local Index = 1 
	local Vectors = {};
	if Folder:FindFirstChild("Anchor") then 
		for i,v in pairs(Folder.Anchor:GetChildren()) do
			if v.Name:sub(1,#v.Name-1) == "Point" and v.Name:sub(#v.Name) == tostring(Index) then 
				Vectors[Index] = {Point = v, CFrame = v.WorldCFrame} 
				Index += 1 
			end
		end
	end

	return Vectors 
end

function CombineTables(a, b)
	local c = {};
	for i,v in pairs(a) do 
		if tonumber(i) then 
			c[#c+1] = v 
		else
			c[i] = v 
		end
	end 
	for i,v in pairs(b) do 
		if tonumber(i) then 
			c[#c+1] = v 
		else
			c[i] = v 
		end
	end 

	return c
end


function weldModel(model)
	for _,g in pairs(model:GetDescendants()) do
		if g:IsA("BasePart") and g ~= model.PrimaryPart then
			local weldconst = Instance.new("WeldConstraint")
			weldconst.Parent = g 
			weldconst.Part0 = g
			weldconst.Part1 = model.PrimaryPart
		end

		if g:IsA("BasePart") then
			g.Anchored = false
		end
	end
end

function unanchorModel(model)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "Anchor" and v.Parent.Name ~= "Attach" then
			v.Anchored = false
		elseif v:IsA("BasePart") and v.Parent.Name == "Attach" then 
			v.CanCollide = false 
		end
	end
end

function GetModelMass(Model)
	local mass = 0
	for i,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then mass += v:GetMass() end 
	end

	return mass
end

-- // Class Functions / Methods

function ObstacleObject.new(Object)
	task.wait() -- Wait for Object Tags to load. 

	local ObstacleController = Knit.GetController("ObstacleController")
	local BuildService = Knit.GetService("BuildService") 

	local Tags        = {}
	local newObstacle = {
		Object = Object 
	}

	for _,v in pairs(game:GetService("CollectionService"):GetTags(Object)) do 
		Tags[v] = true 
	end 

	if Tags["Platform"] then 
		repeat task.wait() until Object.PrimaryPart -- CollectionService tags are triggered BEFORE the model itself is made. 

		print("Adding new Platform Obstacle", Object, Object.PrimaryPart)

		local Settings = {}

		if Object.PrimaryPart:FindFirstChild("Settings") then 
			Settings = CompileValues(Object.PrimaryPart.Settings)
		end

		local MovementAttachment = Instance.new("Attachment")
		MovementAttachment.Parent = Object.PrimaryPart
		MovementAttachment.Name = "Movement"

		local AlignAttachment = Instance.new("Attachment")
		AlignAttachment.Parent = Object.PrimaryPart
		AlignAttachment.Name = "Alignment"
		AlignAttachment.Position = Vector3.new(0,1,0)

		local AlignPos = Instance.new("AlignPosition")
		AlignPos.RigidityEnabled = false
		AlignPos.MaxForce = 1000000
		AlignPos.MaxVelocity = math.huge
		AlignPos.Attachment0 = MovementAttachment
		AlignPos.Responsiveness = Settings.Speed or 10

		AlignPos.Parent = Object.PrimaryPart 

		local AlignOri = Instance.new("AlignOrientation")
		AlignOri.MaxTorque = 1000000
		AlignOri.MaxAngularVelocity = math.huge
		AlignOri.Responsiveness = 200
		AlignOri.Attachment0 = MovementAttachment

		AlignOri.Parent = Object.PrimaryPart

		--[[local AntiGravity = Instance.new("BodyForce")
		AntiGravity.Force = Vector3.new(0,GetModelMass(Object)*workspace.Gravity,0)
		AntiGravity.Parent = Object.PrimaryPart--]]

		local Attach = Object:FindFirstChild("Attach") -- Effects to attach to the model itself. 
		local CurrentOffset = Attach.PrimaryPart.CFrame:ToObjectSpace(Object.PrimaryPart.CFrame) 

		local newObstacle = {
			Object = Object,
			Settings = Settings,

			--- 

			Index = 1, 
			Points = CompileVectors(Object:FindFirstChild("Points")),
			Position = Object.PrimaryPart.Position,
			Rotation = 0,

			AttachOffset = CurrentOffset, 
			AttachTo = Object.PrimaryPart,
			AttachmentModel = Attach,

			---

			MovingToDestination = false; 
			AlignPosition = AlignPos,
			AlignOrientation = AlignOri
		}

		if newObstacle.Points and #newObstacle.Points > 0 then 
			AlignOri.Attachment1 = newObstacle.Points[1].Point
			AlignPos.Attachment1 = newObstacle.Points[1].Point
		end

		unanchorModel(Object)
	elseif Tags["InvisiblePath"] then 
		newObstacle.Tweens = {} 
	elseif (Tags["SpringPad"]) then
		local activation = Object:WaitForChild("Activation")
		local debounce = 0
		newObstacle._touchedEvent = activation.Touched:Connect(function(part)
			--Debounce
			if (part.Parent.Name == "Collider") then return end -- Avoid using the Gravity Collider points as Activation parts. 

			if (os.clock() < debounce) then return end


			local velocity = activation.CFrame.UpVector * (Object:GetAttribute("Velocity") or 150)

			-- Animate pad
			task.spawn(ObstacleController.AnimateSpringPad, Object) 

			--Aero.Controllers.Sound:Play("Effect", "Spring"..tostring(math.random(1,5)))
			
			--Check if this is a character - if so, we need a different way of launching...
			local hum = part.Parent:FindFirstChild("Humanoid")
			local root = part.Parent:FindFirstChild("HumanoidRootPart")
			
			local parent 
			
			if (hum and root) then 
				parent = root
			end 
			
			if (not parent) then
				parent = part 
			end 
			--Set debounce
			debounce = os.clock() + 5

			--Launch player
			local velObj = Instance.new("BodyVelocity")
			velObj.Velocity = velocity
			velObj.MaxForce = Vector3.new(1,1,1)*math.huge
			velObj.P = 100e3
			velObj.Parent = parent

			--Wait for 5 physics frames
			for i = 1, 10 do
				RunService.Heartbeat:wait()
			end

			--Destroy the velocity object
			velObj:Destroy()
	
			BuildService:_useSpringPad(Object) 
		end)
	end 

	-- Always going to need a BodyPosition and BodyGyro...

	local self = setmetatable(newObstacle, ObstacleObject)

	self.Tags = Tags 

	print("New Obstacle:", self.Tags) 

	return self
end

function ObstacleObject:GetDistanceToDestination()
	if (not self.Object.PrimaryPart) then return 0 end 
	return (self.Object.PrimaryPart.Position - self.AlignPosition.Attachment1.WorldPosition).Magnitude 
end

-- This is going to happen on the Server. 
function ObstacleObject:Destroy() 
	if (self.Object) then 
		--self.Object:Destroy() 
		if (self._touchedEvent) then 
			self._touchedEvent:Disconnect() 
		end 
	end 
end 

function ObstacleObject:Update()
	--print(self.Tags)
	if (self.Tags["Platform"]) then 
		if self.AttachmentModel then
			self.AttachmentModel:SetPrimaryPartCFrame(self.AttachTo.CFrame * self.AttachOffset:Inverse())
		end

		if self.MovingToDestination then return end
		self.MovingToDestination = true 

		if #self.Points > 0 then 
			self.AlignPosition.Attachment1 = self.Points[self.Index].Point

			--print("Current Index:", self.Index, #self.Points)
			if self.Index + 1 > #self.Points then 
				--print("Setting to 1")
				self.Index = 1 
			else
				--print("Adding 1")
				self.Index += 1 
			end

			if self.Settings.Time ~= 0 then 
				wait(self.Settings.Time or 3) 
				self.MovingToDestination = false 
			else
				local DistanceToNextPoint = self:GetDistanceToDestination()
				self.Shared.Thread.Spawn(function()
					local timeOut = 600 -- 60 Seconds 
				--repeat wait(.1) DistanceToNextPoint = (self.Object.PrimaryPart.Position - self.Points[self.Index].Point.WorldPosition).Magnitude print("Distance to next point:", DistanceToNextPoint) until DistanceToNextPoint <= 1 
					repeat DistanceToNextPoint = self:GetDistanceToDestination() wait(.1) timeOut -= 1 until DistanceToNextPoint <= 1 or timeOut <= 0 
					self.MovingToDestination = false 
				end)
			end
		end
	elseif (self.Tags["InvisiblePath"]) then 
		--[[local Player = self.Player 
		local Char = Player.Character 
		local HRP  = Char:FindFirstChild("HumanoidRootPart")

		if (HRP) then 
			for i,v in pairs(self.Object:GetChildren()) do 
				local _CFrameReference   = v:FindFirstChild("CFrameReference", true) 
				local _OldTweenReference = v:FindFirstChild("PretweenCFrame", true) 
				local _distance = (HRP.Position - _CFrameReference.Value.p).magnitude 

				--warn("Distance:", _distance)

				if (_distance < 20) then 
					if self.Tweens[v] then 
						if (self.Tweens[v].Played == false) then 
							self.Tweens[v].Played = true

							self.Tweens[v].Tween:Cancel() 
							self.Tweens[v].Tween:Play()
							self.Tweens[v].Tween.Completed:Wait() 

							if (self.Tweens[v].Played == true) then 
								v.CFrame = _CFrameReference.Value
							end   
							print("Playing") 
						end 
					else 
						local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0) 
						self.Tweens[v] = {
							Played = false; 
							Tween  = self.Modules.Tween.new(tweenInfo, function(ratio)
								v.CFrame = _OldTweenReference.Value:lerp(_CFrameReference.Value, ratio)
							end)
						}

						self.Tweens[v].Tween:Play()
						self.Tweens[v].Played = true 
						self.Tweens[v].Tween.Completed:Wait() 

						if (self.Tweens[v].Played == true) then 
							v.CFrame = _CFrameReference.Value
						end   
					end 	
				elseif _distance > 25 then 
					if (self.Tweens[v]) and (self.Tweens[v].Played == true) then 
						print("Reversing") 
						self.Tweens[v].Played = false 

						self.Tweens[v].Tween:Cancel() 
						self.Tweens[v].Tween:Play(true)
						self.Tweens[v].Tween.Completed:Wait()

						if (self.Tweens[v].Played == false) then
							v.CFrame = _OldTweenReference.Value 
						end 
					end 
				end 
			end 
		end --]] 
	end 
end

function ObstacleObject:Init()
	Utility = self.Shared.Utility 
	Aero = self 
	Thread = self.Shared.Thread 
end 


return ObstacleObject