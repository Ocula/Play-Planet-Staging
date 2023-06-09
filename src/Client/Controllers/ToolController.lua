-- Tool Controller
-- @ocula
-- January 2, 2022

--[[

    Tool system is going to be responsible for most player engagement. 
    
    Goals:

        * Respond to as much player input as possible
        * Keep the front-end simple and compact
        * Input should be flexible 

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ToolController = Knit.CreateController({
    Name = "ToolController", 
    currentTool = 1; 
    currentPage = 1; 

    _tools = {};
    _input = nil;  
}) 

-- Internal 

function ToolController:_getInput()

end


--

-- 
function ToolController:JumpTo(_page) 
    
end 

function ToolController:Update()
    -- Update to the current page. 
    if (self.currentTool ~= self._currentPage) then 
        self:JumpTo(self._currentPage) 
    end
end

function ToolController:Show()

end 

function ToolController:Hide()

end 

function ToolController:ProcessInput(_input) -- Will be called from UIS hooks, but only for Keyboard, Mouse, and Gamepad inputs. Touch will be manually connected. 
    for _, tool in pairs(self._tools) do 
        tool:ProcessInput(_input) 
    end 
end 

function ToolController:KnitStart()
    -- Listen for Inputs 
    local _usinp    = Knit.GetController("UserInput") 
    local tool      = require(Knit.Modules.Classes.Tool) 

    tool:Init() 

    local _input    = _usinp:GetPreferredModule() 

    self._input     = _input 
    self._preferred = _usinp:GetPreferred() 

    local listenForInputChange   = _usinp.PreferredChanged:Connect(function(_newPreferred) 
        if (_newPreferred > 1 and self._preferred <= 1) then -- This will also alert us when the player switches from using the keyboard to the mouse. What we really want to check is if they switch from keyboard/mouse to Gamepad or Touch. 
            warn("Preferred User Input method has changed.", _newPreferred)
        end

        self._input = _usinp:GetPreferredModule()
    end)

    local listenForInputRequest = _usinp.ProcessInput:Connect(function(...: any?)
        self:ProcessInput(...) 
    end) 

    -- 0 = Keyboard
    -- 1 = Mouse 
    -- 2 = Gamepad
    -- 3 = Touch 

    -- Create SpringPad Tool
    local _springPad = tool.new("SpringPad", {Equip = {KeyCode = Enum.KeyCode.B, UserInputState = Enum.UserInputState.Begin, UserInputType = Enum.UserInputType.Keyboard}}) -- Set Hotkeys 
    table.insert(self._tools, _springPad)

    warn("Created tools:", self._tools) 
end

function ToolController:KnitInit()
	
end


return ToolController