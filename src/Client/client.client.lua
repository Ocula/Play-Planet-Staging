local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

Knit.Library = {}
Knit.Modules = {}

local Utility = require(Shared.Utility)

local Controllers, Dependencies = script.Parent:WaitForChild("Controllers"), script.Parent:WaitForChild("Dependencies")

-- Load Library Modules (Nevermore Modules @shared & Wally-Installed Modules via Knit @packages, loaded by the Server)
Utility:IndexModules(Shared, Knit.Library)
Utility:IndexModules(Packages, Knit.Library)

-- Load Dependency Modules (Class Modules/Utility Modules for the Server @dependencies)
Utility:IndexModules(Dependencies, Knit.Modules)

-- Add Controllers
Knit.AddControllers(Controllers)

-- Start Knit
Knit.Start():andThen(function() end):catch(warn)
