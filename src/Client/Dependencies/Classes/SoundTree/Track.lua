local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(ReplicatedStorage.Shared.Signal)
local Maid = require(ReplicatedStorage.Shared.Maid) 

local Track = {}
Track.__index = Track


function Track.new(sound: Sound, data: Array)
    local self = setmetatable({
        Master = sound, 
        Volume = 0.5,

        _maid = Maid.new(), 
    }, Track)

    for i,v in pairs(data) do 
        self[i] = v 
    end 
    

    return self
end

function Track:Update(masterPos: number) 
    if not self.Master.Playing then return end 

    if masterPos then 
        self.Master.TimePosition = masterPos 
    end 
end

function Track:Reconcile(masterPos: number)
    local currentTP = self.Master.TimePosition
    local margin = 0.2
    local min, max = currentTP - margin, currentTP + margin 

    if masterPos < min or masterPos > max then 

        warn("OUTSIDE MARGIN:", currentTP, masterPos)

        self.Master.TimePosition = masterPos
    end
end 

function Track:SetVolume(vol: number)
    if not vol then 
        warn("Setting volume of track to: ", self.Volume)
        self.Master.Volume = self.Volume 
        return 
    end

    self.Master.Volume = vol 
    self.Volume = vol 
end 

function Track:Mute() 
    self.Master.Volume = 0
end

function Track:Play()
    self.Master:Play()
end

function Track:Stop()
    self.Master:Stop() 
end 

function Track:Destroy()
    self._maid:DoCleaning() 
end


return Track
