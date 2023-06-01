-- Utility
-- @ocula
-- February 13, 2021
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = {}

local Base64, Binary

function Utility:GetUniqueId()
	local random = Random.new()
	local minRnd = -math.pow(2, 31)
	local maxRnd = math.pow(2, 31) - 1

	--128-bit ID (UUID)
	local GUID0 = random:NextInteger(minRnd, maxRnd) - minRnd
	local GUID1 = random:NextInteger(minRnd, maxRnd) - minRnd
	local GUID2 = random:NextInteger(minRnd, maxRnd) - minRnd
	local GUID3 = random:NextInteger(minRnd, maxRnd) - minRnd

	--Encode to binary string
	--Attempt to call a nil value
	local guidData = Base64.encode( -- so i can differentiate lines
		Binary.encodeInt(GUID0, 4)
			.. Binary.encodeInt(GUID1, 4)
			.. Binary.encodeInt(GUID2, 4)
			.. Binary.encodeInt(GUID3, 4)
	)

	--Use guidData
	return guidData
end

-- Utility Functions
function Utility.splitString(inputStr, delimiter)
	local out = {}
	for str in string.gmatch(inputStr, "([^" .. delimiter .. "]+)") do
		table.insert(out, str)
	end

	return out
end

function Utility.getAssembly(part, found, list)
	if found == nil then
		found = {}
	end
	if list == nil then
		list = {}
	end

	if found[part] then
		return
	end
	found[part] = true
	table.insert(list, part)

	local joints = part:GetJoints()
	for _, joint in ipairs(joints) do
		if not joint:IsA("VectorForce") then
			Utility.getAssembly(joint.Part0, found, list)
			Utility.getAssembly(joint.Part1, found, list)
		end
	end

	return list
end

function Utility.createFolder(name, parent)
	local _folder = Instance.new("Folder")
	_folder.Name = name
	_folder.Parent = parent

	return _folder
end

-- Returns in Top, Middle, Bottom (Top is always white, Middle is the color, and Bottom is a clamped darker version of the color)
function Utility:GetFrameColors(color)
	local hue, saturation, value = Color3.toHSV(color)

	if value < 0.1 then
		value += 0.2
	end

	return Color3.new(1, 1, 1),
		color,
		Color3.fromHSV(hue, math.clamp(saturation + 0.2, 0, 1), math.clamp(value - 0.2, 0, 1))
end

function Utility:FormatStringUpperLower(String)
	local _s1 = String:sub(1, 1)
	_s1 = _s1:upper()

	local _s2 = String:sub(2)
	_s2 = _s2:lower()

	return _s1 .. _s2
end

-- Table Methods // Utility Functions for Table operations.
function Utility:StaticCombineTables(a, b)
	local c = {}
	for i, v in pairs(a) do
		c[i] = v
	end
	for i, v in pairs(b) do
		c[i] = v
	end

	return c
end

--[=[
function CentralizeModel(model)
	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(0.1,0.1,0.1)
	newPart.CFrame = model:GetBoundingBox()
	newPart.CanCollide = false
	newPart.Transparency = 1
	newPart.Parent = model
	newPart.Name = "Center"
	newPart.Anchored = true
	
	
	model.PrimaryPart = newPart
end 

CentralizeModel(game.Selection:Get()[1])
]=]

function Utility:CentralizeModel(model)
	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(0.1, 0.1, 0.1)
	newPart.CFrame = model:GetBoundingBox()
	newPart.CanCollide = false
	newPart.Transparency = 1
	newPart.Parent = model
	newPart.Name = "Center"
	newPart.Anchored = true

	model.PrimaryPart = newPart
end

function Utility:GetTableAmount(tbl)
	local _count = 0

	for i, v in pairs(tbl) do
		_count += 1
	end

	return _count
end

function Utility:FilterTable(_table, ...)
	local TableUtil = require(Knit.Library.TableUtil)
	return TableUtil.Filter(_table, ...)
end

function Utility:CountTable(_table, _condition)
	local _total = 0

	for i, v in pairs(_table) do
		local _pass = true

		if _condition then
			for check, value in pairs(_condition) do
				if v[check] ~= value then
					_pass = false
				end
			end
		end

		if _pass then
			_total += 1
		end
	end

	return _total
end

function Utility:GetRandomTableValue(_table)
	local _count = self:CountTable(_table)

	if _count <= 0 then
		warn("The table passed through Utility is empty")
		return
	end

	local _rand = math.random(1, _count)
	local _num = 0

	for _, value in pairs(_table) do
		_num += 1

		if _num == _rand then
			return value
		end
	end
end

function Utility:SplitString(_string, _split)
	local _table, i = {}, 1
	for _str in _string:gmatch("([^" .. _split .. "]+)") do
		_table[i] = _str
		i = i + 1
	end
	return _table
end

function Utility:GetTags(Object, Omit)
	if not Omit then
		Omit = { ["Interact"] = true }
	end

	--function _getTags(Object, Omit)
	local _tags = {}

	if typeof(Object) == "Instance" then
		local ecapTags = game:GetService("CollectionService"):GetTags(Object)

		if #ecapTags >= 0 then
			for _, v in pairs(ecapTags) do
				if not Omit[v] then
					_tags[v] = true
				end
			end
		end
	elseif type(Object) == "table" then
		_tags["Harvest"] = true
	end

	return _tags
	--end
end

function Utility:FindParent(_instance, _search)
	local _parent = _instance

	while not (_parent == _search) do
		if _parent == game then
			return nil
		end
		_parent = _parent.Parent
	end

	return _parent
end

function Utility:HoldPlayer(_player, pos) -- length might be a callback function maybe?
	if _player then
		local _char = _player.Character

		if _char then
			local _hum = _char:FindFirstChild("Humanoid")
			if _hum then
				if _hum.Health >= 0 then
					local _humRoot = _char:FindFirstChild("HumanoidRootPart")
					local attachment0 = Instance.new("Attachment")
					local alignPosition = Instance.new("AlignPosition")
					attachment0.Parent = _humRoot

					alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
					alignPosition.RigidityEnabled = true
					alignPosition.ApplyAtCenterOfMass = true

					alignPosition.Attachment0 = attachment0
					alignPosition.Position = pos

					alignPosition.Parent = _humRoot

					return alignPosition
				end
			end
		end
	end
end

function Utility:TeleportPlayer(_player, cf, _radius)
	if _player then
		local _char = _player.Character

		if _char then
			local _hum = _char:FindFirstChild("Humanoid")

			if _hum then
				local _humroot = _char:FindFirstChild("HumanoidRootPart")

				if _humroot then
					if _hum.Health >= 0 then
						if not _radius then
							_radius = 0
						end
						_humroot.CFrame = cf
							* CFrame.new((math.random(-_radius, _radius)), 3.5, (math.random(-_radius, _radius)))
					end
				end
			end
		end
	end
end

function Utility:GetModelFromPrimaryPart(PrimaryPart, _workspace)
	-- Try parent first
	if PrimaryPart.Parent:IsA("Model") and PrimaryPart.Parent.PrimaryPart == PrimaryPart then
		return PrimaryPart.Parent
	end

	-- Now we recursively check upwards
	local _currentParent = PrimaryPart
	local _timeout = os.clock()

	local _timeoutLimit = 10

	repeat
		_currentParent = _currentParent.Parent
		wait()
	until _currentParent:IsA("Model") and _currentParent.PrimaryPart == PrimaryPart
		or (not _workspace and _currentParent == workspace)
		or (os.clock() - _timeout >= _timeoutLimit)

	return _currentParent
end

function Utility:ChangeDescendantsColor(search, fromColor, toColor)
	--if (fromColor) then
	-- Get all of the UI objects that have a BackgroundColor3 or ImageColor3 that is equivalent to fromColor
	pcall(function()
		for i, v in pairs(search:GetDescendants()) do
			if v:IsA("GuiObject") then
				if v.BackgroundColor3 == fromColor then
					v.BackgroundColor3 = toColor
				end

				if v.ImageColor3 == fromColor then
					v.ImageColor3 = toColor
				end
			end
		end
	end) -- Lazy
	--end
end

-- Create a cache model Movement function so that we can get precision in model CFraming
-- Don't use on big big big models
function Utility:_GetModelMove(model)
	local primary = model.PrimaryPart
	local primaryCf = primary.CFrame
	local cache = {}
	for _, child in ipairs(model:GetDescendants()) do
		if child:IsA("BasePart") and child ~= primary then
			cache[child] = primaryCf:ToObjectSpace(child.CFrame)
		end
	end

	if #cache > 1000 then
		warn("Model CFrame has exceeded the part limit for performance reasons.", model)
		return false
	end

	return function(cf)
		primary.CFrame = cf
		for part, offset in pairs(cache) do
			part.CFrame = cf * offset
		end
	end
end

-- Scale model
function Utility:ScaleModel(model, scale)
	if not self._scaleCache then
		self._scaleCache = {}
	end

	if model.Parent == nil then
		return
	end
	if model.PrimaryPart == nil then
		return
	end

	local primary = model.PrimaryPart
	local primaryCf = primary.CFrame

	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") and v:IsA("UnionOperation") then
			local _cacheData = self._scaleCache[v]

			if not _cacheData then
				_cacheData = { v.Size, primaryCf:ToObjectSpace(v.CFrame) } --* v.Position}

				self._scaleCache[v] = _cacheData
			end

			local _size = _cacheData[1]
			local _cf = _cacheData[2]

			v.Size = (_size * scale)

			if v ~= primary then
				v.CFrame = primaryCf * (CFrame.new(_cf.X * scale, _cf.Y * scale, _cf.Z * scale))
			end
		end
	end

	return model
end

function Utility:GetLargestBound(Bounds, _Floor, _Ceiling)
	if
		(Bounds.X >= Bounds.Y and Bounds.X >= Bounds.Z)
		and (Bounds.X > (_Floor or 0))
		and (Bounds.X < (_Ceiling or math.huge))
	then
		return Bounds.X
	elseif
		(Bounds.Y >= Bounds.X and Bounds.Y >= Bounds.Z)
		and (Bounds.Y > (_Floor or 0))
		and (Bounds.Y < (_Ceiling or math.huge))
	then
		return Bounds.Y
	elseif
		(Bounds.Z >= Bounds.X and Bounds.Z >= Bounds.Y)
		and (Bounds.Z > (_Floor or 0))
		and (Bounds.Z < (_Ceiling or math.huge))
	then
		return Bounds.Z
	end

	return _Floor or _Ceiling or 0
end

function Utility:SetModelToColor(Model)
	for i, v in pairs(Model:GetDescendants()) do
		if v.Name == "OldColor" or v.Name == "grayscaleReference" then
			v.Parent.Color = v.Value
		end
	end
end

-- Set all the BackgroundColors / ImageColors of Children
function Utility:SetColor(Folder, Color)
	for i, v in pairs(Folder:GetChildren()) do
		if v:IsA("GuiObject") then
			if v:IsA("Frame") then
				v.BackgroundColor3 = Color
			elseif v:IsA("ImageButton") or v:IsA("ImageLabel") then
				v.ImageColor3 = Color
				v.BackgroundColor3 = Color
			end
		end
	end
end

function Utility:SetText(TextFrame, Text)
	for _, v in pairs(TextFrame:GetChildren()) do
		if v:IsA("TextLabel") then
			v.Text = Text
		end
	end
end

function Utility:SetupSignals(_controller)
	if _controller.Signals then
		--- Setup Signals
		local _tableReference = {}

		for i, v in pairs(_controller.Signals) do
			_tableReference[i] = v
		end

		for name, _ in pairs(_tableReference) do
			_controller.Signals[name] = self.Shared.Signal.new()
		end

		return true
	end
end

function Utility:ValueCheck(Object)
	for _, v in pairs(Object:GetChildren()) do
		if v.ClassName:sub(#v.ClassName - 4, #v.ClassName):lower() == "value" then
			return true
		end
	end

	return false
end

function Utility:SetTextLabels(Bin, Text)
	for i, v in pairs(Bin:GetChildren()) do
		if v:IsA("TextLabel") then
			v.Text = Text
		end
	end
end

function Utility:Connect3DButton(ButtonObject, _callback, ...)
	local Button = ButtonObject:FindFirstChild("Button")
	local _Args = { ... }

	if not Button then
		warn("Button does not have a 'Button' child.")
		return
	end

	local _middle = ButtonObject:FindFirstChild("Middle")

	if not _middle then
		_middle = ButtonObject.Background:FindFirstChild("Middle")
	end

	Button.MouseButton1Down:Connect(function()
		_middle:TweenPosition(UDim2.new(0.5, 2, 0, 2), "Out", "Sine", 0.06, true)
	end)

	Button.MouseButton1Up:Connect(function()
		_middle:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Sine", 0.06, true)
		_callback(self, Button, unpack(_Args))
	end)
end

function Utility:WeldModel(Model, Properties)
	if not Model.PrimaryPart then
		warn("Model must have a PrimaryPart set")
		return
	end

	local PrimaryPart = Model.PrimaryPart

	for _, v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") and v ~= PrimaryPart then
			local _newWeldCons = Instance.new("WeldConstraint")
			_newWeldCons.Parent = v
			_newWeldCons.Part0 = v
			_newWeldCons.Part1 = PrimaryPart

			for property, value in pairs(Properties) do
				if v[property] then
					v[property] = value
				end
			end
		end
	end
end

function Utility:IndexModules(folder, to)
	for i, v in pairs(folder:GetChildren()) do
		if v:IsA("ModuleScript") then
			-- Reconcile any clones.
			if to[v.Name] then
				continue
			end

			-- Load module
			--[[local success, module = pcall(function()
				return require(v)
			end)
			if success then--]]
			to[v.Name] = v
			--else
			--	warn("Module load failed on:", v.Name, module)
			--end
		elseif v:IsA("Folder") then
			if v.Name ~= "_Index" then
				to[v.Name] = v
			end
		end
	end
end

function Utility:CompileValues(Object, Action)
	if not Object then
		return nil
	end

	-- Local recursive value check.
	local findValues
	findValues = function(values)
		local out = {}

		if not values then
			warn("Error compiling values for:", Object, Action)
			return {}
		end

		for _, v in pairs(values:GetChildren()) do
			-- If it finds a value, we index it.

			if v.ClassName:sub(#v.ClassName - 4, #v.ClassName):lower() == "value" then
				out[v.Name] = v.Value

				if Action == "Delete" then
					v:Destroy()
				end
			elseif v.ClassName == "Folder" then
				-- Check to see if any sub-models hold important data.
				if Utility:ValueCheck(v) then
					out[v.Name] = findValues(v)
				end
			end
		end

		return out
	end

	return findValues(Object)
end

function Utility:Init()
	Binary = self.Shared.Binary
	Base64 = self.Shared.Base64_Serializer
end

return Utility
