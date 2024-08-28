-- @ocula

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shapecast = {}
Shapecast.__index = Shapecast

function Shapecast.cast(typeOf: string, pos: any?, size: Vector3, direction: Vector3, filter: { any }) 
    local overlapCheck = require(Knit.Library.OverlapCheck)
    local raycastParams = RaycastParams.new() 
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude 
    raycastParams:AddToFilter(filter) 

    if typeOf == "Block" then 
        return workspace:Blockcast(pos, size, direction, raycastParams) 
    elseif typeOf == "Sphere" then
        return workspace:Spherecast(pos, overlapCheck.getRadiusFromSize(size), direction, raycastParams)
    end 
end

function Shapecast.gravityUp(pos: any?, upVector: Vector3)
    Shapecast.cast("Sphere", pos, Vector3.new(3.5,3.5,3.5), -upVector) 
end 

return Shapecast
