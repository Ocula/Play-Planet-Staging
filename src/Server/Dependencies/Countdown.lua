-- Countdown Object by @ocula
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(ReplicatedStorage.Shared.Signal)
local Maid = require(ReplicatedStorage.Shared.Maid) 

local Countdown = {}
Countdown.__index = Countdown


function Countdown.new(start)
    local self = setmetatable({
        _time       = start,
        _changed    = Signal.new(), 
        _maid       = Maid.new(), 
    }, Countdown)

    return self
end

function Countdown:Get()
    return self._time 
end 

function Countdown:Start()
    local RunService = game:GetService("RunService")

    self._conn = RunService.Stepped:Connect(function(dt)
        if self._time - dt <= 0 then 
            self:Destroy() 
            return
        end 
        
        self._time -= dt 
        self._changed:Fire(self._time) 
    end)

    self._maid:GiveTask(self._conn) 
end

function Countdown:Destroy()
    self._maid:DoCleaning() 
end


return Countdown
