-- @Ocula
-- I need a break from trying to fix the First person camera, so we're gonna work on music. 

-- Dynamic Sound System 
-- API:

-- TODO: ADD PLAYBACK SPEED SUPPORT (can use this for really dynamic gameplay)

--[[ 

        Sound:Play(soundId: string)
        Sound:GetSoundTree(stemId: string, omitArray: table, loop: bool) 

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Sound = Knit.CreateController({
    Name = "Sound",

    Trees = {},
})

function Sound:Play(soundId: string, data: array) 

end

function Sound:GetSoundTree(stemId: string)
    return self.Trees[stemId] 
end 

function Sound:CreateSoundTree(stemId: string) -- OmitArray is a table of IDs to omit.
    local soundTree = require(Knit.Modules.Classes.SoundTree) 
    local newStem = soundTree.new(stemId) 

    self.Trees[stemId] = newStem 

    return newStem 
end

function Sound:KnitStart()

    --[[
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        for sound, tree in pairs(self.Trees) do

            if tree._playing then
                tree._masterTimePosition += dt --* tree:GetPlaybackSpeed() 
            end

            tree:UpdateBeat()
        end 
    end) 

    local GameController = Knit.GetController("GameController") 

    local _testTree = self:CreateSoundTree("stems:balderdash")

    local tracks = {"Bass", "Instruments", "Melody"}

    _testTree:MuteTracks(tracks) 
    _testTree:Play()

    GameController.Loaded:Connect(function()
        _testTree:setMeasureHook(function(object)
            object:UpdateTrackPositions(tracks, 0)
            object:UnmuteTracks(tracks) 

            task.wait(object.spliceTrim.X)
            
            object:UpdateTimePosition(object.spliceTrim.X) 
        end) 
    end)--]]
    
end 

function Sound:KnitInit()
    local SoundService = Knit.GetService("SoundService")

    SoundService.SkipSound:Connect(function(id, beat)
        self.Trees[id]:Skip(beat) 
    end)

    SoundService.StopSound:Connect(function(id)
        self.Trees[id]:Stop() 
    end)
end 

return Sound 