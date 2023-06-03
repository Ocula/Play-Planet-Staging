warn("Knit Starting") 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
local PatchCameraModule = ReplicatedStorage.Packages:WaitForChild("patch-cameramodule") 

-- Dependencies for Client bootup
local Utility = require(Shared.Utility)
local Signal = require(Shared.Signal) 

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

-- Camera Injection
--[[local Client = script.Parent
local PlayerModule = Client.Parent:FindFirstChild("PlayerModule") 
local CameraModule = PlayerModule:FindFirstChild("CameraModule")

local PatchCameraModule = require(PatchCameraModule)(CameraModule)

-- Run injections
for i,v in pairs(Client.Controllers.Camera.Inject:GetChildren()) do
    local _inject = require(v)
end

local playerModuleObject = require(PlayerModule) 
local cameraModuleObject = playerModuleObject:GetCameras()

warn("Injected:", cameraModuleObject)--]]

-- Add Controllers
Knit.AddControllers(Controllers)

-- Start Knit
Knit.Start():andThen(function() 
    -- Run Bootup Hooks
    for i, v in pairs(Knit.Bootup) do 
        v:Fire() 
    end 
end):catch(warn)
