-- Terminal Settings
-- Wulfchow
-- June 23, 2020

--[[

    Terminal Settings module for easy control and shared input.

--]]

local Settings = {

    _name   = "Terminal";

    -- list of state true controllers
    _access = {
        [20313136]  = true, -- davidiscooi
        [889918695] = true, -- Jaudr3y
        [9466529]   = true, -- Ocula
        [115636064] = true, -- lollip0ps (Ocula's alt acc)
		[5507877]   = true, -- Wulfchow
        [3910087]	= true, -- foxgod54321
        [3820095]   = true, -- DuskEnfield
        [1094977]   = true, -- ImActuallyAnna
		[-1] = true, -- Testing players
		[-2] = true,
		[-3] = true,
    };
    -- in-chat only command buffer ... e.i '!walkspeed me 10'
    _chatTypeSet       = "!";
    -- opens the local terminal ui
    _activationKey     = Enum.KeyCode.Semicolon;
    _terminalColorKeys = {
        ["print"]   = Color3.fromRGB(255, 255, 255);
        ["error"]   = Color3.fromRGB(255, 73, 73);
        ["command"] = Color3.fromRGB(255, 125, 255);
        ["output"]  = Color3.fromRGB(249, 217, 56);
    };
    -- abstract instance sets for commands, in determining access with local controller given users
    _types = {
        [1] = "Utility",
        [2] = "Moderation",
        [3] = "Debug",
        [4] = "Fun",
    };

    _window = {
        Size     = UDim2.new(0.75, 0, 0, 50);
        Position = UDim2.new(0.125, 0, 1, -150);

        LineHeight = 20;
        MaxHeight  = 200;
    };

    -- chat toggle
    _chatTypeActivated = false;

    -- terminal ui settings
    _closeTerminalAfterSuccessfulCommand = true;

}

return Settings