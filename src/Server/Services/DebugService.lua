local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DebugService = Knit.CreateService({
    Name = "DebugService",
    _activeDebug = true, -- Set to true when we want all warnings/prints to show. 
})

function DebugService.warn(...: any?)
    if DebugService._activeDebug then  
        warn(...) 
    end 
end 

function DebugService.print(...: any?)
    if DebugService._activeDebug then 
        print(...)
    end 
end 

function DebugService:KnitInit()

end 

function DebugService:KnitStart()

end 

return DebugService 