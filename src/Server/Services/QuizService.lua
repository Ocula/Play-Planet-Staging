local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuizService = Knit.CreateService({
	Name = "QuizService",
	Client = {},
})

local Question = require(Knit.Modules.Question)

--

function QuizService:KnitStart() end

function QuizService:KnitInit() end

return QuizService
