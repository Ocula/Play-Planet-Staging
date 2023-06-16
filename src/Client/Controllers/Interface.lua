local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local InterfaceUtils = require(Knit.Library.InterfaceUtils)
local Handler = require(Knit.Modules.Interface.Build.Handler)

-- Fusion primary dependencies
local New = Fusion.New
local State = Fusion.State

-- Fusion secondary dependencies
local Computed = Fusion.Computed
local Children = Fusion.Children

-- Fusion animation dependencies
local Spring = Fusion.Spring
local Tween = Fusion.Tween

local Signal = require(Knit.Library.Signal)

local Interface = Knit.CreateController({
	Name = "Interface",
	serverLoaded = false,
	Buttons = {},

	playerListUpdated = Signal.new(),

	goalWait = 3, -- We dont want the player waiting to load in any longer than 3 seconds.

	_epilepsy = State(true),
	_serverLoad = Signal.new() 
	-- For players with epilepsy. They will be prompted during Load-in on their first visit. Can be changed in settings.
	-- This will wrap any UI calls with a Safety net.
	-- Any running UI can check here
	-- This will mute any flashes. Will not affect gameplay.
})

local clientBegan

--[[ Structurally:
        Mount all roact trees here via their respective modules in Interface
--]]

function Interface:AddButton(buttonObj)
	self.Buttons[buttonObj._object] = buttonObj
end

function Interface:RemoveButton(buttonObj)
	self.Buttons[buttonObj._object] = nil
end

function Interface:Load()
	-- Splash Screen / Loading Bar
	local Load = Handler:Get("Load-screen")
	local LoadObject = Load.new() -- Create new Loading Screen

	-- Aggregate all Assets
	local assets = require(Knit.Library.AssetLibrary):Aggregate()

	local function getCurrentLoadBarPosition()
		local perc = LoadObject:GetLoadingPercentage()
		local amountToGo = 1 - perc

		return (perc + amountToGo / ((math.random((self.goalWait / 2) * 10, (self.goalWait * 10))) / 10))
	end

	ContentProvider:PreloadAsync(assets)

	-- If we haven't loaded on the server yet, give some content to keep it interesting.

	if not self.serverLoaded then
		local _overTime = false
		local _currentTime = os.time()

		local sound = Knit.GetController("Sound") 
		local themeSong = sound.Trees["stems:balderdash"] 

		local _themeSongConnection = themeSong._beatChange:Connect(function()
			local _id = "Shake" .. math.random(1, 3)
			LoadObject:Shake(math.random(10, 30) / 10, _id)
			LoadObject:SetLoadingPercentage(getCurrentLoadBarPosition())
		end)

		self._serverLoad:Wait()

		_themeSongConnection:Disconnect() 

		--[[
		repeat
			local _id = "Shake" .. math.random(1, 3)
			LoadObject:Shake(math.random(10, 30) / 10, _id)
			LoadObject:SetLoadingPercentage(getCurrentLoadBarPosition())

			for _ = 0, 1.5, 0.01 do -- special wait so we dont miss the server loading.
				if self.serverLoaded then
					break
				end

				task.wait(0.01)
			end

			if _currentTime - clientBegan > self.goalWait * 2 then
				warn("Loading timed out...")
				self.serverLoaded = true
			end

		until self.serverLoaded--]]
	end

	local _currentTime = os.time()
	local _timeLeft = _currentTime - clientBegan

	if _timeLeft < self.goalWait then
		local _timeLeftToWait = self.goalWait - _timeLeft
		local inc = 1.5

		for i = 0, _timeLeftToWait, inc do
			task.wait(1)

			local _id = "Shake" .. math.random(1, 3)
			LoadObject:Shake(math.random(10, 30) / 10, _id)

			if i > (_timeLeftToWait - inc) then
				LoadObject:SetLoadingPercentage(1)
			else
				LoadObject:SetLoadingPercentage(getCurrentLoadBarPosition())
			end
		end
	end

	task.wait(0.1)

	-- Open doors!
	LoadObject:SetLoadingPercentage(1)
	LoadObject:Shake(3)
	LoadObject:SetDoor(0.6)

	task.wait(1)

	LoadObject:Hide()

	task.wait(1)

	LoadObject:Destroy()
end

function Interface:KnitStart()
	-- Test Fusion
	self:Load() -- Add to self:Load()
	local Transitions = Handler:Get("Transitions") -- This inits the Transition folder.

	-- Triangle test
	local Test = Transitions:Get("PaintOut")

	-- Interface Button Testing
	--[[
	local Button = Handler:Get("Buttons/ButtonObject")
	local AssetLibrary = require(Knit.Library.AssetLibrary)
	local Pattern = AssetLibrary.Assets.Interface.Textures.Giraffe

	local ButtonTest = Button.new("Textured", {
		Name = "ButtonTest",
		PatternID = Pattern,
		ImageRectOffset = State(Vector2.new(0, 0)),
		Parent = TestContainer,
		Position = UDim2.new(0.3, 0, 0.5, 0),
		Size = UDim2.new(0, 150, 0, 50),
		Text = "Menu",
		ButtonColor = Color3.fromRGB(246, 175, 236),
	}, function()
		print("Button clicked")
	end)

	ButtonTest:Animate() --]]

	--[[ TODO: Fix these splatters... need some other elements to it. Something to give it umpf --]]
	-- repeat

	--[[local splat = Handler:Get("Effects/Small/Splatter")

	--		for i = 1, 3 do
	local SplatterSize = math.random(4, 8) / 10
	local Movement = 3 / 10 + (math.random(-2, 2) / 10)
	local Splatter = splat.new(
		UDim2.new(SplatterSize, 0, SplatterSize, 0),
		UDim2.new(0.3 + Movement, 0, 0.3 + Movement, 0),
		"CartoonSplatter" .. math.random(1, 12)
	)

	Splatter:Play()

	task.delay(6, function()
		Splatter:Hide()
	end)
	--		end

	task.wait(1)
	--	until 2 == 3
	--]]

	--self:Load()
	-- test
	--local RoundArea = require(Knit.Modules.Interface.Controllers.RoundArea)

	--RoundArea:Init()
	--RoundArea:Start()
end

function Interface:KnitInit()
	-- Interface init
	local GameController = Knit.GetController("GameController")
	local RoundService = Knit.GetService("RoundService")

	RunService:BindToRenderStep("ButtonRender", Enum.RenderPriority.Last.Value, function()
		for i, v in pairs(self.Buttons) do
			v:Render()
		end
	end)

	GameController.Loaded:Connect(function(bool)
		self.serverLoaded = bool
		self._serverLoad:Fire() 
	end)

	RoundService.CountdownChanged:Connect(function(object, count)
		local element = self.Interfaces[object]

		if element then
			if count then
				element.Element.props.Countdown = count
			else
				element.Element.props.Countdown = element.Element.props.TimerMax
			end
		end
	end)

	RoundService.PlayerListChanged:Connect(function(object, list)
		local element = self.Interfaces[object]

		if element then
			local _newList = {}

			-- Create player element? But we don't need to anymore.

			element.Element.props.Headcount = self.Count(_newList)
			element.Element.props.PlayerList = _newList
		end
	end)

	RoundService.PlayerLobbyStatusChanged:Connect(function(_inLobby)
		if not _inLobby then
			--self:Halt()
		else
			--self:Start()
		end
	end)

	clientBegan = GameController:getClientBegan() -- Time that the game starts.
end

return Interface
