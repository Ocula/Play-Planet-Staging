-- Character controller used to attach any events to the character model. Events can be
-- disconnected on death, or reconnected on death.
--
-- Example events are setup below. Need to clean this up with a proper Maid task and Promise system.
--
-- Ocula @ Dec 3, 2022

-- This is redundant you idiot. You shouldn't be connecting these events via the Client. Do it via the Server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EventClass = require(Knit.Modules.charEvent)

local character = Knit.CreateController({
	Name = "character",
	Objects = {},

	Events = {},
})

function character:AddEvent(_event)
	local _newEvent = EventClass.new(_event)

	table.insert(self.Events, _newEvent)
end

function character:CreateObjects()
	local _partAnchor = Instance.new("Part")
	_partAnchor.Parent = self.Character
	_partAnchor.Size = Vector3.new(2, 2, 2)
	_partAnchor.CanCollide = false
	_partAnchor.Transparency = 0.4
	_partAnchor.Color = Color3.new(0.074509, 0.501960, 0)

	-- Body Objects

	-- Index
	self.Objects.Anchor = _partAnchor
end

function character.InitCharacter()
	character.Character = character.Player.Character
	character.Humanoid = character.Character:WaitForChild("Humanoid")
	character.HRP = character.Character:WaitForChild("HumanoidRootPart")

	--warn("Indexed new character:", character.Character)
end

function character:KnitStart()
	self.Player = game.Players.LocalPlayer

	self:AddEvent({
		Name = "Init Character",
		Type = "Added",
		Fired = character.InitCharacter,
	})

	self:AddEvent({
		Name = "Unhook Character",
		Type = "Removing",
		Fired = function()
			--warn("Character removing")
		end,
	})

	self.Player.CharacterAdded:Connect(function()
		for _, v in pairs(self.Events) do
			if v.EventType:lower() == "added" then
				v.Bind:Fire()
			end
		end
	end)

	self.Player.CharacterRemoving:Connect(function()
		for _, v in pairs(self.Events) do
			if v.EventType:lower() == "removing" then
				v.Bind:Fire()
			end
		end
	end)
end

function character:KnitInit() end

return character
