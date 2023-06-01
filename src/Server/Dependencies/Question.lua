local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Question = {}
Question.__index = Question

function Question.new() end

function Question:createDoors() end

return Question
