-- @ocula 
-- Sound Stem.lua

--[[

    SoundTree Object
        -> Inside of it, each sound is fed into a Stem Class
            -> Track Classes handle the logic for all individual stems. Separates out the intro / middle loop / outro.
            -> When you play an individual stem it will play intro & middle, and then outro will only play when Stop(_outro = true) is called. 
            -> 

    (Beats / Minute) ÷ (60 Seconds) = Seconds per beat

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Shared.Maid)
local Signal = require(ReplicatedStorage.Shared.Signal) 

local SoundTree = {}
SoundTree.__index = SoundTree

function SoundTree.new(stemId: string)
    local ItemIndexService = Knit.GetService("ItemIndexService")
    local Track = require(script.Track) 
    local object

    ItemIndexService:GetSound(stemId):andThen(function(stemObject)
        object = stemObject 
    end):await() 

    local self = setmetatable({
        Object                 = object.Object:Clone(),
        BPM                    = 120,
        TimeSignature          = "4/4",
        PlaybackSpeed          = 1, 
    
        Stems                  = {},

        _currentBeat           = 0,
        _currentMeasure        = 0,
        _masterTimePosition    = 0,
    
        _beatChange            = Signal.new(),
        _measureChange         = Signal.new(),
        _onMeasureHookComplete = Signal.new(), 
        _maid                  = Maid.new(),
    
        _measureHook           = nil,
        _playing               = false,
        
    }, SoundTree)

    -- Get attributes
    for name, property in pairs(self.Object:GetAttributes()) do 
        self[name] = property 
    end 

    -- Set Tracks
    for i,v in pairs(self.Object:GetChildren()) do 
        self.Stems[v.Name] = Track.new(v, self:Package()) 
    end

    -- Get seconds per beat
    self._secondsPerBeat = 60 / self.BPM
    self.totalBeats = math.floor(self.TimeLength / self._secondsPerBeat)

    -- Check that TimeLength is set.
    assert(self.TimeLength, "Sound Tree must have a time length set manually.")
    
    -- Set Events
    self._beatChange:Connect(function(newBeat)
        self._currentBeat = newBeat 
    end)

    self._measureChange:Connect(function(newMeasure)
        self._currentMeasure = newMeasure

        if self._measureHook and not self._measureHookBusy then 
            self._measureHookBusy = true 

            task.spawn(function()
                self._measureHook(self) -- only fires once. can yield. 
                self._measureHook = nil
                self._onMeasureHookComplete:Fire() 
                self._measureHookBusy = false 
            end) 

            return
        end

        for i,v in pairs(self.Stems) do
            if not self._measureHookBusy then 
                v:Reconcile(self._masterTimePosition)
            end 
        end
    end)

    self:Splice()

    -- Cleanup Duties
    self._maid:GiveTask(self.Object) 
    self.Object.Parent = game:GetService("SoundService") 

    return self 
end

function SoundTree:GetTimePositionFromAudio()
    local timePos = 0 

    for i,v in pairs(self.Stems) do 
        timePos = v.Master.TimePosition 
    end 

    return timePos 
end 

function SoundTree:GetPlaybackSpeed()
    local speed = self.Object:GetAttribute("PlaybackSpeed")

    if self.PlaybackSpeed ~= speed then 
        if not self._originBPM then 
            self._originBPM = self.BPM
        end 

        self._secondsPerBeat = 60 / (self._originBPM * self.PlaybackSpeed)
        self._masterTimePosition = self:GetTimePositionFromAudio()

        for i,v in pairs(self.Stems) do 
            v.Master.PlaybackSpeed = speed 
        end 

        self.PlaybackSpeed = 1 

        --self:Splice() 
    end

    return speed 
end 

function SoundTree:Splice()
    local trim = Vector2.new(0,0) 

    if self.IntroBeats then 
        assert(self.IntroBeats, "If stem has an intro, you must outline how many beats it is by setting an IntroBeats attribute.")
        trim += Vector2.new(self._secondsPerBeat * self.IntroBeats, 0)
    end 

    if self.OutroBeats then 
        assert(self.OutroBeats, "If stem has an outro, you must outline how many beats it is by setting an OutroBeats attribute.")
        trim += Vector2.new(0, self.TimeLength - (self._secondsPerBeat * self.OutroBeats))
    end

    self.spliceTrim = trim
end

function SoundTree:Package()
    return {
        secondsPerBeat = self._secondsPerBeat,
        TimeSignature = self.TimeSignature, 
        TimeLength = self.TimeLength, 
        Loop = self.Loop, 
        BPM = self.BPM, 
    }
end

function SoundTree:isPlaying() 
    for i,v in pairs(self.Stems) do 
        if v.Master.Playing then 
            return true 
        end 
    end 

    return false 
end 

function SoundTree:setMeasureHook(func: any?)
    assert(type(func) == "function", "Bad function.")
    self._measureHook = func 
end

function SoundTree:UpdateTrackPositions(trackNames, position)
    for i, trackName in pairs(trackNames) do
        self.Stems[trackName]:Update(position) 
    end
end

function SoundTree:ReconcileTracks()
    for i,v in pairs(self.Stems) do 
        v:Update(self._masterTimePosition)
    end 
end 

function SoundTree:UnmuteTracks(trackNames: array)
    for i, trackName in pairs(trackNames) do
        self.Stems[trackName]:SetVolume() 
    end
end 

function SoundTree:MuteTracks(trackNames: array)
    for i,trackName in pairs(trackNames) do 
        self.Stems[trackName]:Mute() -- use Mute to mute so that when we turn off mute, we stay at our saved Volume setting.
    end
end 

function SoundTree:SetTrackVolume(trackName: string, volume: number)
    self.Stems[trackName]:SetVolume(volume)
end 

function SoundTree:UpdateTimePosition(forceTimePosition: number)
    if forceTimePosition then 
        self._masterTimePosition = forceTimePosition 

        for i,v in pairs(self.Stems) do 
            v.Master.TimePosition = self._masterTimePosition 
        end 

        self:UpdateBeat() 
    end
end


function SoundTree:UpdateBeat()
    -- For every track, check if it's on a queue track.
    -- If it isn't, make sure everyone is at the same place.
    -- Handle loop queues here.

    -- Queue Priorities -> SoundTree has top priority.
    --      Stem has second.
    
    local now               = self._masterTimePosition
    local beat              = math.floor(now / self._secondsPerBeat) 
    local beatsPerMeasure   = tonumber(self.TimeSignature:sub(1,1)) 

    -- Check loop

    local nextMeasure = now + (self._secondsPerBeat * (beatsPerMeasure * 2))

    if nextMeasure >= self.TimeLength and not self._loopDeb and not self._measureHookBusy then
        self._loopDeb = true 

        --warn("Setting loop measurehook")

        self:setMeasureHook(function(object)
            if self.OutroBridge then 
                local bridge = self.OutroBridge
                object:Skip(bridge.X)
                --warn("Skipped to bridge transition") 
                task.wait( ((bridge.Y - bridge.X) * object._secondsPerBeat) / self.PlaybackSpeed)
                object:UpdateTimePosition(self.spliceTrim.X)
            end
        end) 

        task.spawn(function()
            self._onMeasureHookComplete:Wait()
            self._loopDeb = false 
            --warn("loop debounce set to false")
        end)
    end

    --

    if beat ~= self:GetCurrentBeat() then
        --warn("Updating Beat:", beat)
        self._beatChange:Fire(beat)

        local newMeasure = math.floor(beat / beatsPerMeasure)

        if newMeasure ~= self:GetCurrentMeasure() then 
            --warn("Updating Measure:", newMeasure) 
            self._measureChange:Fire(newMeasure) 
        end 
    end
end 

function SoundTree:GetCurrentBeat()
    return self._currentBeat 
end 

function SoundTree:GetCurrentMeasure()
    return self._currentMeasure
end 

function SoundTree:Skip(_beat)
    self:UpdateTimePosition(_beat * self._secondsPerBeat)
end 

function SoundTree:Play() -- Request play on all sound stems at once.
    self._playing = true 

    for i,v in pairs(self.Stems) do 
        v:Play() 
    end 
end

function SoundTree:Stop()
    self:setMeasureHook(function()
        warn("setting to:", self.totalBeats - self.OutroBeats)

        self:Skip((self.totalBeats - self.OutroBeats))

        task.wait((self.OutroBeats) * self._secondsPerBeat) 
    end)

    self._onMeasureHookComplete:Wait() 

    for i,v in pairs(self.Stems) do 
        warn("stopping") 
        v:Stop()
    end 

    self._playing = false
end 

function SoundTree:Destroy()
    self._maid:DoCleaning() 
end


return SoundTree

