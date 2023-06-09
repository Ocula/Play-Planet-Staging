-- @ocula GravityField [Server] 

--[[

    Fields:
        * Required
        - State ("Normal", "GravityField")
        - Object (GravityZone) 

        * Optional
        - Gravity (Number, default 196.2 - this will be supported on the backend but won't have any real implementations until much later)
        - Priority (Number, default 0) - The higher the priority, the higher the precedence. If you have Gravity Fields inside of Gravity Fields, this will become important. 
        - UpVector [Global] (Vector3, default is nil - this will lock the players into a specific UpVector in this field)
            - If nil, the client will calculate the UpVector based on player position to field, assuming sphere. 
            - This can also be changed during runtime and clients will update in response. So we can play with wonkier gravity during games. 
            - For example a race inside a building where the UpVectors switch from 0,1,0 and 0,-1,0 every 10 seconds or something.
        - UpVectorMultiplier (Number, default: 1)
            - This is a branch off the earlier concept, an example of use case:
                - If player is on a planet inside of a big inverted sphere, we can set UpVector Multiplier to -1 / 1 and they'll switch between inside/outside. 
    
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(ReplicatedStorage.Shared.Maid) 

local GravityField = {}
GravityField.__index = GravityField

-- @ocula
-- Create a new Gravity Field. Server authorized only. 
function GravityField.new(fieldObject)
    if not fieldObject:FindFirstAncestorOfClass("Workspace") then 
        return {_ShellClass = true, Object = fieldObject, Destroy = function() end}
    end 

    local gravityZone = fieldObject:FindFirstChild("GravityZone") or {Value = nil}
    local upVector = fieldObject:GetAttribute("UpVector") 

    -- If the UpVector isn't manually set, then we'll check if it has a GravityZone Value. If no GravityZone value AND no manual UpVector, we run into problems. 
    if not upVector then 
        assert(gravityZone.Value ~= nil, "GravityField could not find a GravityZone set. Make sure to place an ObjectValue pointing to the GravityObject.")
    end 

    local rootObject = gravityZone.Value 

    local overlapCheck = require(Knit.Library.OverlapCheck)
    local attributes = fieldObject:GetAttributes()

    -- Only place in Relative CFs on specific objects, maybe? 
    local newField = {
        GUID = game:GetService("HttpService"):GenerateGUID(false),

        -- World Positioning
        Relative = fieldObject.CFrame:ToObjectSpace(rootObject.CFrame),
        Center = fieldObject.CFrame, 
        Root = rootObject, 
        Object = fieldObject,

        -- Field Properties
        State = "Normal",
        Gravity = 196.2,
        Priority = 0, 
        UpVector = nil,
        UpVectorMultiplier = Vector3.new(1,1,1), -- >:) 
        Enabled = true, 

        -- Field Checking
        Field = overlapCheck.new(fieldObject), 
        Size = fieldObject.Size,

        -- Cleanup
        _maid = Maid.new() 
    }

    for property, value in pairs(attributes) do 
        newField[property] = value 
    end

    if newField.UpVector == nil then -- If we have no manual upvector and we're in a block zone, we can find that UpVector pretty easily on our own.
        if fieldObject.Shape == Enum.PartType.Block then 
            newField.UpVector = fieldObject.CFrame.YVector
        end 
    end
    
    local self = setmetatable(newField, GravityField)

    --

    self._maid:GiveTask(self.Root:GetPropertyChangedSignal("CFrame"):Connect(function()
        self.Object.CFrame = self.Relative:ToWorldSpace(self.Root.CFrame) 
        self.Center = fieldObject.CFrame  
    end))

    return self
end

-- @ocula 
-- Package Gravity Field for client usage. 
function GravityField:Package()
    local _package = {
        GUID = self.GUID, 
        -- Coordinates
        Center = self.Object.CFrame,
        Relative = self.Relative, 
        -- Field Props
        -- Object = self.Object, 
        -- Root = self.Root, 
        State = self.State;
        Gravity = self.Gravity;
        Priority = self.Priority; 
        -- UpVector updates
        UpVector = self.UpVector;
        UpVectorMultiplier = self.UpVectorMultiplier,
    }

    return _package
end

-- @ocula
-- Set all GravityField properties with this function so we know to reconcile.
function GravityField:Set(index: string, value: any?)
    local GravityService = Knit.GetService("GravityService") 

    self[index] = value 

    local reconcileUpdate = self:Reconcile() 
    
    for i,v in pairs(game.Players:GetPlayers()) do 
        GravityService.Client.ReconcileField:Fire(v, reconcileUpdate) 
    end
end 

-- @ocula
-- Reconciles all properties to Clients
function GravityField:Reconcile()
    if not self.reconcile then 
        self.reconcile = self:Package() 
    end

    local update = {
        GUID = self.GUID 
    } 

    for indexCheck, value in pairs(self) do
        if type(value) ~= "table" then 
            local recCheck = self.reconcile[indexCheck]
            if recCheck and recCheck ~= value then
                update[indexCheck] = value
            end

            self.reconcile[indexCheck] = value 
        end 
    end

    self.reconcile = self:Package()

    return update
end 

-- @ocula
-- Get UpVector on GravityField. 
function GravityField:GetUpVector(pos: Vector3) -- We can use this function to get more detailed UpVectors
    -- This can also be used for NPCs.
    if self.UpVector then -- Block Zone (typically going to point the players into one direction regardless) 
        return self.UpVector * self.UpVectorMultiplier
    else -- Radial Zone (typically pulling the player towards the center of a sphere) 
        local center = self.Center.p 
        local upVector = (pos - center).Unit 

        return upVector * self.UpVectorMultiplier
    end 
end 

function GravityField:GetPriority()
    return self.Priority 
end 

function GravityField:GetPosition()
    return self.Center.p 
end

function GravityField:GetDistanceFrom(pos: Vector3)
    return (self.Center.p - pos).Magnitude 
end 

function GravityField:isPlayerIn(player)
    -- Overlap Check for Player!
    local humRoot = player:GetHumanoidRootPart()

    if humRoot then 
        return self.Field:Check(humRoot) 
    end 
end 

--[[

This can happen on the client for more accurate UpVector positioning. 

function GravityField:GetGravityUp(Request: any?)
    if self.UpVector then 
        return self.UpVector * self.UpVectorMultiplier 
    end

    local Shapecast = require(Knit.Library.Shapecast) 

    if Request:IsA("BasePart") then
        -- ShapeCast
        return Shapecast.gravityUp(Request.Position, self:GetUpVector())
    elseif Request:IsA("Vector3") then 
    end 
end --]]

function GravityField:Destroy()
    self._maid:DoCleaning() 
end


return GravityField
