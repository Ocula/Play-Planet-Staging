-- Spring Pad
-- @ocula
-- January 3, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = ReplicatedStorage:WaitForChild("Shared") 
local Utility = require(Shared:WaitForChild("Utility")) 

local SpringPad = {}
SpringPad.__index = SpringPad 


function SpringPad.new(_hotkeys) 
    local self  = setmetatable({
        Hotkeys     = _hotkeys; 
        Cooldown    = 3; 
        Inputs      = {
            Rotate  = {
                {KeyCode = Enum.KeyCode.Q, UserInputState = Enum.UserInputState.Begin; UserInputType  = Enum.UserInputType.Keyboard; _args = {"Left"}}; 
                {KeyCode = Enum.KeyCode.E, UserInputState = Enum.UserInputState.Begin; UserInputType  = Enum.UserInputType.Keyboard; _args = {"Right"}}; 
            };

            Place   = {
                {UserInputState = Enum.UserInputState.Begin, UserInputType = Enum.UserInputType.MouseButton1, _args = {}};
            }
        };

        _previewObj = nil;
        _cooling    = false; 
        _cantPlace  = false; 
        _pad        = "pads:basic"; -- Change this to whatever we're allowed to change it to, y'know. When the time comes. 

        _equipped   = false; 
        _rotate     = 0;
    }, SpringPad) 


    return self 
end

function SpringPad:_createPreview()
    if (not self._equipped) then return end 

    if (not self._previewObj) then
        local ItemIndexService = Knit.GetService("ItemIndexService") 
        local getObject = ItemIndexService:GetItem(self._pad):andThen(function(index)

            local _obj  = index.Object:Clone() 

            game:GetService("CollectionService"):RemoveTag(_obj, "ObstacleObject")

            -- Create hitbox
            local hitbox        = Instance.new("Part")
            hitbox.Name         = "Hitbox"
            hitbox.CFrame       = _obj.PrimaryPart.CFrame 
            hitbox.Size         = _obj:GetModelSize()
            hitbox.Parent       = _obj 
            hitbox.Anchored     = true 
            hitbox.Transparency = 1
            hitbox.CanCollide   = false 

            self._hitbox = hitbox 

            -- Move it 
            local plr = game.Players.LocalPlayer 
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart") 

            if (plr and hrp) then 
                _obj:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0,5,-10)) 
            end 

            _obj.Parent = workspace.game.bin.client 

            -- Prep object
            for i, v in pairs(_obj:GetDescendants()) do 
                if (v:IsA("BasePart") or v:IsA("UnionOperation")) then 
                    if (v.Transparency < 1) then 
                        v.CanCollide = false 
                        v.Transparency = 0.8
                        v.BrickColor = BrickColor.new("Teal")
                    end 
                end 
            end

            self._previewObj = _obj
            self._movePreview = Utility:_GetModelMove(_obj) 

            if (not self._movePreview) then 
                warn("SpringPad cannot move a SpringPad with that many parts!") 
                self:Unequip()
            end 
        end)
    end 
end

function SpringPad:_placeCast(hrp)
    local origin        = hrp.CFrame * CFrame.new(0,10,-10) -- Start high so we can place springpads up there. 
    local towards       = origin * CFrame.new(0,-20,0) 

    local _direction    = (towards.p - origin.p).Unit * 1000 
    local parameters    = RaycastParams.new() 

    parameters.FilterType = Enum.RaycastFilterType.Blacklist 
    parameters.FilterDescendantsInstances = {self._previewObj, workspace.game.bin.sandbox}

    return workspace:Blockcast(origin, self._hitbox.Size, _direction, parameters) 
end 

function SpringPad:Update()

    if (not self._previewObj) then 
        return 
    end 

    if (not self._cooling and not self._cantPlace) then 
        self:_setPreviewPlaceable(true)
    else 
        self:_setPreviewPlaceable(false) 
    end 

    local Player = game.Players.LocalPlayer 
    local HRP    = Player.Character:FindFirstChild("HumanoidRootPart")

    if (HRP) then 
        local _raycast = self:_placeCast(HRP) 
        local _face    = (HRP.CFrame * CFrame.new(0,10,-10)) 

        if (_raycast) then 
            -- Move preview 
            local _size = self._previewObj:GetModelSize() 
            local _oldCF = self._previewObj.PrimaryPart.CFrame 
            local _newCF = CFrame.new(_raycast.Position, _raycast.Position + (_raycast.Normal * 2)) * CFrame.Angles(-math.pi/2,self._rotate,0) * CFrame.new(0,(_size.Y/2 * 0.75),0)

            self._movePreview(_oldCF:lerp(_newCF, 0.4))

            -- Check if can place 
            if (self._hitbox) then  
                if (not self._cooling) then 
                    local filter = OverlapParams.new()
                    filter.FilterType = Enum.RaycastFilterType.Blacklist 
                    filter.FilterDescendantsInstances = {self._previewObj, workspace.game.bin.sandbox} 

                    local _parts = workspace:GetPartsInPart(self._hitbox, filter)

                    local _failCheck = false 
                    for i,v in pairs(_parts) do 
                        if (game:GetService("CollectionService"):HasTag(v, "PlacedObject")) then 
                            _failCheck = true 
                            break 
                        end
                    end 

                    self._cantPlace = _failCheck 
                end 
            end 
        else 
            self:_setPreviewPlaceable(false) 
        end 
    end 
end 

function SpringPad:Equip()
    if (self._equipped) then self:Unequip() return end 

    self._equipped = true

    if (not self._previewObj) then 
        self:_createPreview() 
    end 

    game:GetService("RunService"):BindToRenderStep("SpringPad", Enum.RenderPriority.Camera.Value - 1, function()
        self:Update() 
    end)
end 

function SpringPad:Unequip()
    if (self._equipped == false) then return end 
    self._equipped = false 

    if (self._previewObj) then 
        self._previewObj:Destroy()
        self._previewObj  = nil 
        self._movePreview = nil 
    end

    game:GetService("RunService"):UnbindFromRenderStep("SpringPad") 
end 

function SpringPad:Rotate(_direction)
    --warn("Rotating:", _direction)
    if (_direction == "Left") then 
        self._rotate -= math.pi/2
    elseif (_direction == "Right") then 
        self._rotate += math.pi/2 
    end 

    if (self._rotate % (math.pi * 2) == 0) then
        --warn("Resetting rotate") 
        self._rotate = 0 
    end
end 

function SpringPad:_checkPreviewPlaceable()
    local _prev = self._previewObj

    if (_prev) then 
        local _prim = _prev.PrimaryPart


    end 
end 

-- Disabling placing 
function SpringPad:_setPreviewPlaceable(_bool)
    if (self._previewObj) then 
        for _, v in pairs(self._previewObj:GetDescendants()) do 
            if (v:IsA("BasePart") or v:IsA("UnionOperation")) then 
                if (v.Transparency < 1) then 
                    if (_bool == false) then 
                        v.Transparency = 0.5
                        v.BrickColor = BrickColor.new("Really red")
                    else
                        v.Transparency = 0.8
                        v.BrickColor = BrickColor.new("Teal")
                    end 
                end 
            end 
        end
    end
end 

function SpringPad:Place()
    -- Place 
    if (not self._previewObj or not self._equipped or self._cooling or self._cantPlace) then return end 

    self._cooling = true 

    local BuildService = Knit.GetService("BuildService") 
    BuildService:Build(self._pad, self._previewObj:GetModelCFrame())

    --self.Controllers.Sound:Play("Effect", "BubbleClick"..math.random(1,5))

    task.delay(0.5, function()
        self._cooling = false 
    end)
end

function SpringPad:_getActiveHotkeys(_input)
    local _functions = {} 

    for func, inputCheck in pairs(self.Hotkeys) do 
        if (_input.UserInputType == inputCheck.UserInputType and _input.UserInputState == inputCheck.UserInputState and _input.KeyCode == inputCheck.KeyCode) then 
            _functions[func] = self[func] 
        end 
    end 

    return _functions
end

function SpringPad:_checkActiveInputs(_input)
    for func, inputdata in pairs(self.Inputs) do 
        for _, data in pairs(inputdata) do
            local _pass = true 

            -- All should be true. 
            for check, value in pairs(data) do
                if (check ~= "_args") then  
                    if (_input[check] ~= value) then
                        _pass = false 
                    end
                end
            end

            if (_pass) then 
                self[func](self, unpack(data._args or {}))
            end 
        end 
    end 
end 

function SpringPad:ProcessInput(_input, processed) 
    --if (processed) then return end 
    -- Check Hotkeys 
    
    local _hotKeys = self:_getActiveHotkeys(_input) 
    if (_hotKeys) then 
        for _name, func in pairs(_hotKeys) do
            warn("func", _name, func)
            func(self) 
        end 
    end

    self:_checkActiveInputs(_input) 
end

function SpringPad:Init()

end 

return SpringPad