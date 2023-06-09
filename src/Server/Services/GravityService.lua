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

    Fields = {},
    _nodes = {}, 
})
-- Private Methods

-- Client Methods
function GravityService.Client:RequestUpVector(player, forceFieldId: string)
    local PlayerService = Knit.GetService("PlayerService") 
    local playerCharacter = player.Character 

    if playerCharacter then 
        local hrp = playerCharacter:FindFirstChild("HumanoidRootPart")

        local playerObject = PlayerService:GetPlayer(player)

        if hrp and playerObject then 
            -- Check if the server sees this field. 
            local fieldId = playerObject.Field or forceFieldId 

            if fieldId then
                --[[if forceFieldId ~= playerObject.Field then -- Will be triggered by latency.
                    warn(player, "is requesting an UpVector of a field that they aren't parented to.", forceFieldId, playerObject.Field)
                    return nil 
                end--]] 

                return self.Server.Fields[fieldId]:GetUpVector(hrp.Position)
            else 
                warn(player, "is requesting an UpVector of a Field that they aren't parented to.")
            end
        end 
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