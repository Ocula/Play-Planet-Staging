-- @ocula

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shapecast = {}
Shapecast.__index = Shapecast

function Shapecast.cast(type: string, pos: any?, size: Vector3, direction: Vector3) 
    local overlapCheck = require(Knit.Library.OverlapCheck)
    local raycastParams = RaycastParams.new() 

    if type == "Block" then 
        return workspace:Blockcast(pos, size, direction, raycastParams) 
    elseif type == "Sphere" then
        assert(type(pos) == "Vector3", "Position given to Shapecast is not a Vector3")
        return workspace:Spherecast(pos, overlapCheck.getRadiusFromSize(size), direction, raycastParams)
    end 
end

function Shapecast.gravityUp(pos: any?, upVector: Vector3)
    Shapecast.cast("Sphere", pos, Vector3.new(3.5,3.5,3.5), -upVector) 
end 

return Shapecast
