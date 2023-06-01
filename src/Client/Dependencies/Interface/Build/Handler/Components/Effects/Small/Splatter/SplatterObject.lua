local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Handler = require(Knit.Modules.Interface.get)

-- Fusion primary dependencies
local New = Fusion.New

-- Fusion secondary dependencies
local Children = Fusion.Children

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SplatterElement = Handler:Get("Effects/Small/Splatter/SplatterElement")

return function(props)
	return New("ScreenGui")({
		Parent = PlayerGui,
		IgnoreGuiInset = true,

		[Children] = {
			Splatter = SplatterElement(props),
		},
	})
end
