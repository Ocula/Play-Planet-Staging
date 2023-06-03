--[[
    @ocula

    GravityCamera State for GravityFieldCameras
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Camera Dependencies
local CameraUtils = require(Knit.Modules.CameraUtils)
local CameraState = require(Knit.Modules.CameraState)

-- Object Dependencies
local BaseObject = require(Knit.Library.BaseObject)
