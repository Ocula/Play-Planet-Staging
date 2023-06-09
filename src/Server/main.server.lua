local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Dependencies = script.Parent:WaitForChild("Dependencies")

local Utility = require(Shared:WaitForChild("Utility"))

-- Replace Player Module 
local GravityPlayerModulePackage = require(Dependencies:FindFirstChild("gravity-camera"))

GravityPlayerModulePackage.replace(
    GravityPlayerModulePackage.getCopy(true)
)

-- Create Game Bin
local directory = Instance.new("Folder")
directory.Parent = workspace 
directory.Name = "game"

local bin = Instance.new("Folder")
bin.Parent = directory 
bin.Name = "bin"

local client = Instance.new("Folder")
client.Parent = bin 
client.Name = "client" 

local server = Instance.new("Folder")
server.Parent = bin 
server.Name = "server" 

-- Create Sandbox
local sandbox = Instance.new("Folder")
sandbox.Parent = bin 
sandbox.Name = "sandbox"

-- Knit

Knit.Library = {}
Knit.Modules = {}

local loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent

-- Load Nevermore Modules
require(loader).bootstrapGame(ServerScriptService.Nevermore)

-- Load Library Modules (Nevermore Modules @shared & Wally-Installed Modules via Knit @packages)
Utility:IndexModules(Shared, Knit.Library)
Utility:IndexModules(Packages, Knit.Library)

-- Load Server Dependencies (Class Modules/Utility Modules for the Server)
Utility:IndexModules(Dependencies, Knit.Modules)

-- Load Services
local Services = script.Parent:WaitForChild("Services")

Knit.AddServices(Services)

Knit.Start():andThen(function() end):catch(warn)
