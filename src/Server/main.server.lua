local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Dependencies = script.Parent:WaitForChild("Dependencies")

local Utility = require(Shared:WaitForChild("Utility"))

Knit.Library = {}
Knit.Modules = {}

local loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent

-- Load Nevermore Modules
local Nevermore = require(loader).bootstrapGame(ServerScriptService.Nevermore)

-- Load Library Modules (Nevermore Modules @shared & Wally-Installed Modules via Knit @packages)
Utility:IndexModules(Shared, Knit.Library)
Utility:IndexModules(Packages, Knit.Library)

-- Load Server Dependencies (Class Modules/Utility Modules for the Server)
Utility:IndexModules(Dependencies, Knit.Modules)

-- Load Services
local Services = script.Parent:WaitForChild("Services")

Knit.AddServices(Services)

Knit.Start():andThen(function() end):catch(warn)
