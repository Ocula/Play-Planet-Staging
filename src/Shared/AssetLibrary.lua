local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local RunService = game:GetService("RunService")
local AssetLibrary = {}
AssetLibrary.__Index = AssetLibrary

AssetLibrary.Assets = {
	Interface = {
		Textures = {
			Giraffe = {
				ID = "rbxassetid://12179976153",
				Size = Vector2.new(1024, 1024),
			},
			SquareSquiggles = {
				ID = "rbxassetid://12181829304",
				Size = Vector2.new(1024, 1024),
			},
		},
		Buttons = {
			PaintDrip1 = {
				ID = "rbxassetid://12181502342",
				Size = Vector2.new(500, 100),
			},
			PaintDrip2 = {
				ID = "rbxassetid://12181515975",
				Size = Vector2.new(500, 100),
			},
			FadeUp = {
				ID = "rbxassetid://12180711062",
				Size = Vector2.new(1024, 1024),
			},
		},
		Splash = { -- Legacy ID System for UI assets
			Building = {
				ID = "rbxassetid://11948927290",
				Size = Vector2.new(771, 318),
			},
			Roof = {
				ID = "rbxassetid://11948927468",
				Size = Vector2.new(872, 451),
			},
			LeftDoor = {
				ID = "rbxassetid://11948927017",
				Size = Vector2.new(188, 318),
			},
			RightDoor = {
				ID = "rbxassetid://11948926929",
				Size = Vector2.new(188, 318),
			},
			Silo = {
				ID = "rbxassetid://11967563839",
				Size = Vector2.new(256, 871),
			},
			Grass = {
				ID = "rbxassetid://11948927132",
				Size = Vector2.new(984, 119),
			},
			BackgroundTexture = {
				ID = "rbxassetid://11967350158",
				Size = Vector2.new(1024, 1024),
			},
			StripeTexture = {
				ID = "rbxassetid://11991918473",
				Size = Vector2.new(1024, 1024),
			},
		},

		Game = {
			Splatters = {
				Cartoon = { -- 12 to use
					-- Cartoony splatters, use for more UI base interactions
					CartoonSplatter1 = {
						ID = "rbxassetid://12157341441",
						Size = Vector2.new(1334, 1305),
					},
					CartoonSplatter2 = {
						ID = "rbxassetid://12157341138",
						Size = Vector2.new(1288, 1094),
					},
					CartoonSplatter3 = {
						ID = "rbxassetid://12157340890",
						Size = Vector2.new(1184, 1127),
					},
					CartoonSplatter4 = {
						ID = "rbxassetid://12157340588",
						Size = Vector2.new(1046, 932),
					},
					CartoonSplatter5 = {
						ID = "rbxassetid://12157340282",
						Size = Vector2.new(1158, 1051),
					},
					CartoonSplatter6 = {
						ID = "rbxassetid://12157339975",
						Size = Vector2.new(916, 753),
					},
					CartoonSplatter7 = {
						ID = "rbxassetid://12157339752",
						Size = Vector2.new(824, 903),
					},
					CartoonSplatter8 = {
						ID = "rbxassetid://12157339394",
						Size = Vector2.new(794, 874),
					},
					CartoonSplatter9 = {
						ID = "rbxassetid://12157339015",
						Size = Vector2.new(995, 788),
					},
					CartoonSplatter10 = {
						ID = "rbxassetid://12157338846",
						Size = Vector2.new(846, 854),
					},
					CartoonSplatter11 = {
						ID = "rbxassetid://12157338675",
						Size = Vector2.new(772, 737),
					},
					CartoonSplatter12 = {
						ID = "rbxassetid://12157338498",
						Size = Vector2.new(825, 704),
					},
				},
				Striking = { -- 19 splatters to use.
					-- Striking splatters. Good for kills / quick flash UI.
					StrikingSplatter1 = {
						ID = "rbxassetid://12157073938",
						Size = Vector2.new(1085, 1203),
					},
					StrikingSplatter2 = {
						ID = "rbxassetid://12157073682",
						Size = Vector2.new(979, 991),
					},
					StrikingSplatter3 = {
						ID = "rbxassetid://12157073472",
						Size = Vector2.new(791, 809),
					},
					StrikingSplatter4 = {
						ID = "rbxassetid://12157073305",
						Size = Vector2.new(1085, 897),
					},
					StrikingSplatter5 = {
						ID = "rbxassetid://12157073000",
						Size = Vector2.new(1070, 1037),
					},
					StrikingSplatter6 = {
						ID = "rbxassetid://12157072590",
						Size = Vector2.new(875, 899),
					},
					StrikingSplatter7 = {
						ID = "rbxassetid://12157072418",
						Size = Vector2.new(896, 949),
					},
					StrikingSplatter8 = {
						ID = "rbxassetid://12157072242",
						Size = Vector2.new(1085, 1093),
					},
					StrikingSplatter9 = {
						ID = "rbxassetid://12157072067",
						Size = Vector2.new(926, 902),
					},
					StrikingSplatter10 = {
						ID = "rbxassetid://12157071859",
						Size = Vector2.new(1085, 981),
					},
					StrikingSplatter11 = {
						ID = "rbxassetid://12157071599",
						Size = Vector2.new(1085, 1055),
					},
					StrikingSplatter12 = {
						ID = "rbxassetid://12157071370",
						Size = Vector2.new(1085, 1059),
					},
					StrikingSplatter13 = {
						ID = "rbxassetid://12157070978",
						Size = Vector2.new(966, 905),
					},
					StrikingSplatter14 = {
						ID = "rbxassetid://12157070790",
						Size = Vector2.new(892, 906),
					},
					StrikingSplatter15 = {
						ID = "rbxassetid://12157070565",
						Size = Vector2.new(1159, 1121),
					},
					StrikingSplatter16 = {
						ID = "rbxassetid://12157070343",
						Size = Vector2.new(1061, 986),
					},
					StrikingSplatter17 = {
						ID = "rbxassetid://12157070111",
						Size = Vector2.new(775, 934),
					},
					StrikingSplatter18 = {
						ID = "rbxassetid://12157069926",
						Size = Vector2.new(1301, 880),
					},
					StrikingSplatter19 = {
						ID = "rbxassetid://12157069710",
						Size = Vector2.new(906, 823),
					},
				}, -- More noise to these splatters... use for in-match purposes.
				Wall = {
					WallSplatter1 = {
						ID = "rbxassetid://12156990479",
						Size = Vector2.new(1737, 565),
					},
					WallSplatter2 = {
						ID = "rbxassetid://12156990236",
						Size = Vector2.new(1648, 491),
					},
					WallSplatter3 = {
						ID = "rbxassetid://12156989989",
						Size = Vector2.new(1543, 703),
					},
					WallSplatter4 = {
						ID = "rbxassetid://12156989773",
						Size = Vector2.new(1460, 384),
					},
					WallSplatter5 = {
						ID = "rbxassetid://12156989632",
						Size = Vector2.new(1389, 604),
					},
					WallSplatter6 = {
						ID = "rbxassetid://12156989435",
						Size = Vector2.new(1336, 1334),
					},
					WallSplatter7 = {
						ID = "rbxassetid://12156989047",
						Size = Vector2.new(1653, 2198),
					},
					WallSplatter8 = {
						ID = "rbxassetid://12156988416",
						Size = Vector2.new(1868, 1840),
					},
					WallSplatter9 = {
						ID = "rbxassetid://12156987937",
						Size = Vector2.new(2289, 1499),
					},
				}, -- Dripping down the wall
			},
			Match = {},
		},
	},

	Audio = { -- Audio is organized by {[id], [timeToStart], [timeToEnd]}
		UI = {},
		Game = {
			Theme = {},
			Effects = {
				Shake1 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					--End = 0.76,
					PlaybackSpeed = 0.8,
				},
				Shake2 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					--End = 1.4,
					PlaybackSpeed = 0.9,
				},
				Shake3 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					PlaybackSpeed = 0.7,
				},
			},
		},
	},
}

function AssetLibrary.search(query, scope)
	local result, parent

	local function recursiveSearch(target)
		if result then
			return
		end

		for searchindex, value in pairs(target) do
			if searchindex == "__Index" then
				continue
			end

			if result then
				break
			end

			if searchindex == query then
				result = value
				break
			else
				if type(value) == "table" then
					parent = target
					recursiveSearch(value)
				end
			end
		end
	end

	recursiveSearch(scope or AssetLibrary)

	return result, parent
end

function AssetLibrary.getRandom(scope)
	local currentScope = scope

	if not currentScope then
		currentScope = AssetLibrary.Assets
	end

	local randomObject = Utility:GetRandomTableValue(scope)

	return randomObject
end

function AssetLibrary.get(index, scope)
	local searchResult = AssetLibrary.search(index, scope)

	if not searchResult then
		warn(
			"Could not find the asset with the identification number that you are looking for. Double check your search query!",
			index
		)
		return
	end

	return searchResult
end

function AssetLibrary.getMap(search)
	return AssetLibrary.get(search, AssetLibrary.Game)
end

function AssetLibrary:BuildServer()
	local GameBin = game:GetService("ServerStorage"):WaitForChild("Game")
	local bin = {}

	local function build(parent, tbl)
		for i, v in pairs(tbl) do --
			if type(v) == "userdata" then
				if not v:IsA("Folder") then
					parent[v.Name] = v
				else
					if v:GetAttribute("Ignore") then
						continue
					end

					parent[v.Name] = {}
					build(parent[v.Name], v:GetChildren())
				end
			end
		end
	end

	build(bin, GameBin:GetChildren())

	self.Assets.Game = bin
end

function AssetLibrary:Aggregate()
	if not RunService:IsClient() then
		return
	end
	-- Get an array of all IDs

	local _array = {}

	local function getAssets(x)
		for i, v in pairs(x) do
			if type(v) == "string" and v:sub(1, 13):lower() == "rbxassetid://" then
				table.insert(_array, v)
			elseif type(v) == "table" then
				getAssets(v)
			end
		end
	end

	getAssets(self.Assets)

	return _array
end

return AssetLibrary
