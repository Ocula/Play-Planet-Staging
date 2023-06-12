-- @ocula 
-- Sound Stem.lua

--[[

    SoundStem Object
        -> Inside of it, each sound is turned into a Stem Class
            -> Stem Classes handle the logic for all individual stems. Separates out the intro / middle loop / outro.
            -> When you play an individual stem it will play intro & middle, and then outro will only play when Stop(_outro = true) is called. 
            -> 

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Shared.Maid)
local Signal = require(ReplicatedStorage.Shared.Signal) 

local SoundStem = {}
SoundStem.__index = SoundStem

function SoundStem.new(stemId: string)
    local ItemIndexService = Knit.GetService("ItemIndexService")

    local self = setmetatable({}, SoundStem)

    ItemIndexService:GetSound(stemId):andThen(function(stemObject) 
        local object = stemObject.Object:Clone()
        -- 
        self.Object         = object 
        self.BPM            = object:GetAttribute("BPM") or 120
        self.Stems          = {}

        self.SplicePoint    = self.BPM / 60 -- get seconds per beat. 

        self._currentBeat           = 0 
        self._masterTimePosition    = 0
        self._beatChange            = Signal.new() 
        self._maid                  = Maid.new() 
        self._playing               = false 
        
        self._beatChange:Connect(function(newBeat)
            self._currentBeat = newBeat 
        end)
        
        self.Object.Parent = game:GetService("SoundService") 
        
        for i,v in pairs(self.Object:GetChildren()) do 
            self.Stems[v:GetAttribute("Priority") or 1] = v 
        end
    
        self._maid:GiveTask(self.Object) 
    end)

    repeat task.wait() until self.Object

    if not self._timePositionEvent then 
        self._timePositionEvent = game:GetService("RunService").Heartbeat:Connect(function(dt)
            self:UpdateBeat()
            if self._playing then 
                self._masterTimePosition += dt
            end 
        end) 

        self._maid:GiveTask(self._timePositionEvent) 
    end 

    return self
end

function SoundStem:UpdateTimePosition(forceTimePosition: number)
    for i,v in pairs(self.Stems) do 
        v.TimePosition = forceTimePosition or self._masterTimePosition
        warn("Set timepos:", v.TimePosition)
    end 

    if forceTimePosition then 
        self._masterTimePosition = 0 
    end
end 

function SoundStem:UpdateBeat()
    local now = self._masterTimePosition
    local splice = math.floor(now / self.SplicePoint) 

    if splice > self:GetCurrentBeat() then
        warn("updating beat", splice) 
        self._beatChange:Fire(splice) 
    end
end 

function SoundStem:GetCurrentBeat()
    return self._currentBeat 
end 

function SoundStem:Set(stemNumber: number)
    -- First check to see that we're at a correct time to be able to play another stem.
    -- Stems have to match up at TimePositions and we only want to start playing the next stem 
    -- at the start of the next measure.

    task.spawn(function() 
        local timePosition = self._masterTimePosition 

        if timePosition > 0 then
            repeat 
                self._beatChange:Wait()
            until (self._currentBeat + 1) % 4 == 0 

            if startAgain then
                --[[local mult = math.floor(self._masterTimePosition / self.SplicePoint) 
                local sub = self._masterTimePosition - (mult * self.SplicePoint)

                warn("SUB:", sub) 

                localStartPosition = sub--]]
                self:UpdateTimePosition(0)
            end 
        end 

        self.Stems[stemNumber]:Play()
        self.Stems[stemNumber].TimePosition = self._masterTimePosition

        if not self._playing then 
            self._playing = true 
        end 
    end) 
end 

function SoundStem:Play() -- Request play on all sound stems at once.
end

function SoundStem:Stop()
    self._playing = false 
end 

function SoundStem:Destroy()
    self._maid:DoCleaning() 
end


return SoundStem

