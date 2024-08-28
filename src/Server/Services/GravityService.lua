-- GravityService for Server Handling of Gravity System.
-- This should probably be responsible for setting Player's Gravity Fields. 

--[[

How it should work: 

    - All Gravity Fields should be created and managed on the server.
        - Once created, GravityService will notify all clients and keep them updated on what fields are active/inactive. 
        - Client will literally only need to handle UpVector calculation every frame. Everything else should be decided by the server.
        - We can technically do away with the client Gravity Field class system and migrate it to the server. 
        - Clients will have Gravity Fields that only return UpVectors based on Player's position. 

        * Moving Gravity Fields:
            - Gravity Fields will always update to be their runtime relative position to their field object. 
            - For example
                - If we want to rotate a moon around a planet and let the player jump up to the moon, the field has to move with the planet.
                - All planetary object movement will happen on the server.

    - Players can then request a gravity field / switch and the server can approve or deny it based on:
        - 1) Player position / proximity to Gravity Field. If they are out of range: deny. 
        - 2) If Player is trying to access an area they aren't allowed to access: deny. 
        - 3) All else, approve.

    * For maximum security, the server should handle all field changes and field updates... but:
        - This is extremely expensive to do on-server. If we have clients request and then server approves or denies those requests, it would be much cheaper.
        - And then just for added security, the server will keep all client fields consistent to what's recorded on the server.
    * Client will request nearest gravity field
    * Server will either approve or deny that. 
    * Server will update field on Player Module. 

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GravityService = Knit.CreateService({
    Name = "GravityService", 
    Client = {
        SetState = Knit.CreateSignal(), 
        SetField = Knit.CreateSignal(), 
        ReconcileField = Knit.CreateSignal() 
    },

    Colliders = {},
    Fields = {},
    _nodes = {}, 
})

local CUSTOM_PHYSICAL = PhysicalProperties.new(0.3, 1, 0, 1, 100)

-- Private Methods

-- Client Methods
function GravityService.Client:RequestUpVector(player, forceFieldId: string, position: Vector3?)
    local PlayerService = Knit.GetService("PlayerService") 
    local playerCharacter = player.Character 

    if playerCharacter then 
        local playerObject = PlayerService:GetPlayer(player)

        if playerObject then 
            -- Check if the server sees this field. 
            local fieldId = playerObject.Field or forceFieldId 

            if fieldId then
                --[[if forceFieldId ~= playerObject.Field then -- Will be triggered by latency.
                    warn(player, "is requesting an UpVector of a field that they aren't parented to.", forceFieldId, playerObject.Field)
                    return nil 
                end--]] 

                return self.Server.Fields[fieldId]:GetUpVector(position) 
            else 
                warn(player, "is requesting an UpVector of a Field that they aren't parented to.")
            end
        end 
    end 
end

function GravityService.Client:GetCollider(Player: Player)
    return self.Server:GetCollider(Player) 
end 

function GravityService:GetCollider(Player: Player)
    local Collider = self.Colliders[Player] 

    if Collider and Collider.Object:IsDescendantOf(workspace) then 
        return Collider 
    else 
        local function getHipHeight(character)
            local humanoid = character:WaitForChild("Humanoid") 

            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                return humanoid.HipHeight + 0.05
            end

            return 2
        end

        local HipHeight = getHipHeight(Player.Character)
        local Model = Instance.new("Model") 

        Model.Name = "Collider" 
        Model.Parent = Player.Character 

        local _conn
        
        _conn = Model.DescendantRemoving:Connect(function()
            Player.Character:BreakJoints() 

            if _conn then 
                _conn:Disconnect()
            end 
        end)

        -- Sphere 
        local Sphere = Instance.new("Part")
		Sphere.Name = "Sphere"
		Sphere.Size = Vector3.new(2, 2, 2)
		Sphere.Shape = Enum.PartType.Ball
		Sphere.Transparency = 0
		Sphere.CustomPhysicalProperties = CUSTOM_PHYSICAL
        Sphere.Parent = Model 

        Model.PrimaryPart = Sphere 

        local FloorDetector = Instance.new("Part")
		FloorDetector.Name = "FloorDectector"
		FloorDetector.CanCollide = false
        FloorDetector.Massless = true 
		FloorDetector.Size = Vector3.new(2, 1, 1)
		FloorDetector.Transparency = 1
        FloorDetector.Parent = Model 

        local JumpDetector = Instance.new("Part")
		JumpDetector.Name = "JumpDectector"
		JumpDetector.CanCollide = false
        JumpDetector.Massless = true 
		JumpDetector.Size = Vector3.new(2, 0.2, 1)
		JumpDetector.Transparency = 1
        JumpDetector.Parent = Model 

        local weld = Instance.new("Weld")
		weld.C0 = CFrame.new(0, -Sphere.Size.Y - 1, 0)
		weld.Part0 = Sphere --.HRP
		weld.Part1 = FloorDetector
		weld.Parent = FloorDetector 
        weld.Name = "Floor"

		local weld = Instance.new("Weld")
		weld.C0 = CFrame.new(0, -Sphere.Size.Y/2, 0)
		weld.Part0 = Sphere --.HRP
		weld.Part1 = JumpDetector
		weld.Parent = JumpDetector--]]

        local sphereAttach = Instance.new("Attachment")
		sphereAttach.Parent = Sphere

        local WalkForce = Instance.new("VectorForce")
		WalkForce.Force = Vector3.new(0, 0, 0)
		WalkForce.ApplyAtCenterOfMass = true
        WalkForce.Name = "WalkForce" 
		WalkForce.RelativeTo = Enum.ActuatorRelativeTo.World
		WalkForce.Attachment0 = sphereAttach -- attach
		WalkForce.Parent = Sphere

        local GForce = Instance.new("VectorForce")
		GForce.Force = Vector3.new(0, 0, 0)
		GForce.ApplyAtCenterOfMass = true
        GForce.Name = "GForce" 
		GForce.RelativeTo = Enum.ActuatorRelativeTo.World
		GForce.Attachment0 = sphereAttach -- attach
		GForce.Parent = Sphere

        local GyroAttachment0 = Instance.new("Attachment") 
		GyroAttachment0.Parent = Sphere
		GyroAttachment0.Name = "Align"
		GyroAttachment0.Visible = true 

        local Gyro = Instance.new("AlignOrientation")
		Gyro.Parent = Sphere
		Gyro.Attachment0 = GyroAttachment0
		Gyro.Responsiveness = 200 
		Gyro.MaxTorque = 500000000000000
		Gyro.Mode = Enum.OrientationAlignmentMode.OneAttachment

		FloorDetector.Touched:Connect(function() end)
		JumpDetector.Touched:Connect(function() end)

        Sphere:SetNetworkOwner(Player)

        local newCollider = {
            Sphere = Sphere, 
            FloorDetector = FloorDetector, 
            JumpDetector = JumpDetector, 
            WalkForce = WalkForce, 
            GForce = GForce, 
            Gyro = Gyro, 
            GyroAttachment0 = GyroAttachment0,
            Object = Model
        }

        self.Colliders[Player] = newCollider 

        return newCollider
    end 
end 

function GravityService:GetFieldFromObject(object)
    for i,v in pairs(self.Fields) do
        if v.Object == object then 
            return v 
        end 
    end   
end 



-- Public Methods
function GravityService:GetNearestField(player: Player) 
    local PlayerService = Knit.GetService("PlayerService")
    local Player = PlayerService:GetPlayer(player)

    if not player then return nil end 

    local Position = Player:GetPosition() 

    if Position then 
        local Search = self.FieldOctree:RadiusSearch(Position, 500) 
        local FieldsIn = {} 

        local highestPriority, highestField = 0, nil 

        for i, v in pairs(Search) do 
            local Field = self.Fields[v] 

            if not Field.Enabled then 
                continue 
            end

            if Field:isPlayerIn(Player) then
                local check = FieldsIn[Field.Priority]

                if check then 
                    warn("The player is inside two fields but both have the same PriorityValue! Make sure to check these so they're different.")
                end 

                FieldsIn[Field.Priority] = Field 

                if Field.Priority > highestPriority then 
                    highestPriority = Field.Priority 
                    highestField = Field
                end 

                if highestField == nil then 
                    highestField = Field 
                end 
            end 
        end

        return highestField 
    end 
end 

function GravityService:SetNearestFields()
    -- Cycle through players. 
    local Players = Knit.GetService("PlayerService"):GetPlayers() 

    for i,v in pairs(Players) do 
        local _nearest = self:GetNearestField(v.Player) 

        if _nearest then 
            v:SetField(_nearest)
        end
    end 
end 

-- For now heartbeat update. But ... we can find a better one I think. 
function GravityService:Update() -- Check our player's fields and set them to what they are on the server. 
    self:SetNearestFields() 
end 

function GravityService:KnitStart()
    -- Setup Binder for Gravity Fields
    local Binder = require(Knit.Library.Binder) 
    local Class = require(Knit.Modules.GravityField)

    local GravityZoneBinder = Binder.new("GravityZone", Class)
    
    self.FieldOctree = require(Knit.Library.Octree).new() 

    GravityZoneBinder:GetClassAddedSignal():Connect(function(newClass)
        if newClass._ShellClass then return end 

        local nodeTrack = self.FieldOctree:CreateNode(newClass:GetPosition(), newClass.GUID)
        
        self._nodes[newClass.GUID] = nodeTrack 
        self.Fields[newClass.GUID] = newClass 
    end) 

    GravityZoneBinder:GetClassRemovingSignal():Connect(function(oldClass)
        if oldClass._ShellClass then return end 

        local node = self._nodes[oldClass.GUID]
        
        if node then 
            node:Destroy() 
        end 

        self.Fields[oldClass.GUID] = nil 
    end)

    GravityZoneBinder:Start() 

    game:GetService("RunService").Heartbeat:Connect(function()
        self:Update() 
    end)

    -- upvector test ;)
    --[[task.spawn(function()
        local zone = workspace.RoundArea:FindFirstChild("Zone") 

        while true do 
            task.wait(10)

            local field = self:GetFieldFromObject(zone)
            local currentMultiplier = field.UpVectorMultiplier

            field:Set("UpVectorMultiplier", -currentMultiplier) 

            print("Playing with Gravity Switch", field.UpVectorMultiplier)  
        end 
    end) --]]
end 

function GravityService:KnitInit()

end 

return GravityService 