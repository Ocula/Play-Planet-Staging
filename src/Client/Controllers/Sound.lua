-- @Ocula
-- I need a break from trying to fix the First person camera, so we're gonna work on music. 

-- Dynamic Sound System 
-- API:
--[[ 

        Sound:Play(soundId: string)
        Sound:PlayStem(stemId: string, omitArray: table, loop: bool) 

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Sound = Knit.CreateController({
    Name = "Sound",

    _active = {}; 
})

function Sound:Play(soundId: string, data: array) 

end

function Sound:PlayStem(stemId: string, data: array, omitStems: array) -- OmitArray is a table of IDs to omit.
    local soundStem = require(Knit.Modules.Classes.SoundStem) 
    local newStem = soundStem.new(stemId, data, omitStems) 

    return newStem 
end 

function Sound:KnitStart()
    local _testStem = self:PlayStem("stems:balderdash")
    _testStem:Play(1)

    task.wait(1) 
    for i = 2,4 do
        _testStem:Play(i, true) 
    end 
end 

function Sound:KnitInit()

end 

return Sound 