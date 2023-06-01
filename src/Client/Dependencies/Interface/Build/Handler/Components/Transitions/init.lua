local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Handler = require(Knit.Modules.Interface.get)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

-- Create a Transitions ScreenGUI that will always have first priority in indexing.
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TransitionBin = New("ScreenGui")({
	Parent = PlayerGui,
	Name = "Transitions",
	DisplayOrder = 0,
})

local Transition = {}
Transition.__index = Transition

function Transition:Get(transitionType)
	local TransitionModule = Handler:Get("Transitions/" .. transitionType)

	if not TransitionModule then
		error("Wrong transition given.")
	end

	-- Create the transition object and place it in our Transition bin.
	return TransitionModule
end

function Transition:In() end

function Transition:Out() end

return Transition
