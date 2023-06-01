-- Puzzle Service
-- @ocula
-- July 15, 2021

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local PuzzleService = Knit.CreateService({
	Name = "PuzzleService",
	Client = {},
	Puzzles = {},
})

function PuzzleService:KnitStart()
	local CServ = game:GetService("CollectionService")

	local _binder = require(Knit.Library.Binder)
	local _puzzleBinder = _binder.new("Puzzle", require(Knit.Modules.Puzzle))

	_puzzleBinder:GetClassAddedSignal():Connect(function(Puzzle)
		if Puzzle and not Puzzle._ShellClass then
			if self.Puzzles[Puzzle.Object] then
				warn("Puzzle class already created for that puzzle.", Puzzle.Object:GetFullName())
				return
			end

			self.Puzzles[Puzzle.Object] = Puzzle
		end
	end)

	local hideAddedSignal = CServ:GetInstanceAddedSignal("Hide")
	local hideRemovedSignal = CServ:GetInstanceRemovedSignal("Hide")

	hideAddedSignal:Connect(function(Object)
		--	local interactableToHide = self.Interactables[Object]
		--	interactableToHide.Interface:SetEnabled(false)
	end)

	hideRemovedSignal:Connect(function(Object)
		--	local interactableToHide = self.Interactables[Object]
		--	interactableToHide.Interface:SetEnabled(true)
	end)

	_puzzleBinder:Start()
end

function PuzzleService:KnitInit() end

return PuzzleService
