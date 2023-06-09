warn("Knit Starting") 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
local PatchCameraModule = ReplicatedStorage.Packages:WaitForChild("patch-cameramodule") 

-- Dependencies for Client bootup
local Utility = require(Shared:WaitForChild("Utility"))
local Signal = require(Shared:WaitForChild("Signal"))

Knit.Library = {}
Knit.Modules = {}
Knit.Bootup = {}

local Controllers = script.Parent:WaitForChild("Controllers")
local Dependencies = script.Parent:WaitForChild("Dependencies")

-- Load Library Modules (Nevermore Modules @shared & Wally-Installed Modules via Knit @packages, loaded by the Server)
Utility:IndexModules(Shared, Knit.Library)
Utility:IndexModules(Packages, Knit.Library)

-- Load Dependency Modules (Class Modules/Utility Modules for the Server @dependencies)
Utility:IndexModules(Dependencies, Knit.Modules)

-- Add Controllers
Knit.AddControllers(Controllers)

-- Start Knit
Knit.Start():andThen(function() 
    -- Run Bootup Hooks
    for i, v in pairs(Knit.Bootup) do 
        v:Fire() 
    end 
end):catch(warn)
