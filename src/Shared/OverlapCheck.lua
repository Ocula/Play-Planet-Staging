-- @ocula Spatial Query System for Checking Zones
-- Feed OverlapCheck.new a part
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Shared.Maid) 

local OverlapCheck = {}
OverlapCheck.__index = OverlapCheck

function OverlapCheck.new(Part)
    local self = setmetatable({
        Object = Part,
        Shape = Part.Shape, 
        Params = OverlapParams.new(), 
        _check = {}, 
        _maid = Maid.new(), 
    }, OverlapCheck)

    self._maid:GiveTask(self.Object) 

    return self
end

-- Public Functions
function OverlapCheck.getRadiusFromSize(size: Vector3)
    return (size.X + size.Y + size.Z)/3
end 

function OverlapCheck:GetBallRadius(object: BasePart?)
    local rObject = object or self.Object 
    assert(rObject.Shape == "Ball", "Object passed to Radius Check is not a Ball!")

    local radius = self.getRadiusFromSize(rObject.Size) 

    return radius
end 

function OverlapCheck:Add(Parts: table)
    for i,v in pairs(Parts) do 
        self._check[v] = false 
    end

    self:Check() 
end

function OverlapCheck:Remove(Part: BasePart)
    self._check[Part] = nil 
end 

function OverlapCheck:Index(Part: BasePart)
    return self._check[Part]
end 

function OverlapCheck:Check(forceCheckForPart: BasePart?) 
    local partsInBounds 

    if self.Shape == "Ball" then 
        partsInBounds = workspace:GetPartBoundsInRadius(self.Object.Position, self:GetBallRadius(), self.Params) 
    else
        partsInBounds = workspace:GetPartBoundsInBox(self.Object.CFrame, self.Object.Size, self.Params)
    end

    local checkAgainst = {}

    for index, part in pairs(partsInBounds) do 
        checkAgainst[part] = true 

        if part == forceCheckForPart then 
            return true
        end 
    end

    for i,v in pairs(self._check) do 
        local index = checkAgainst[v]
        self._check[i] = (index ~= nil) 
    end

    if forceCheckForPart then 
        return false 
    end 
end 

function OverlapCheck:Destroy()
    self._maid:DoCleaning() 
end


return OverlapCheck

