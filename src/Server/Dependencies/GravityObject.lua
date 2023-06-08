-- @ocula GravityObject [Server]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GravityObject = {}
GravityObject.__index = GravityObject


function GravityObject.new() -- We might not even need this lol 
    --[[local GravityField = require(Knit.Modules.GravityField) 
    local Field = Object:FindFirstChild("Field")

    local self = setmetatable({
        Field = GravityField.new(Field.Value, Object)
    }, GravityObject)
    return self--]]
end


function GravityObject:Destroy()
    
end


return GravityObject

