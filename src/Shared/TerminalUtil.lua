-- Terminal Util
-- Wulfchow
-- June 23, 2020

local TerminalUtil = {}

local Maid
local ArrayMaid

local Checks = {
    [1] = { "me,myself", function(_player)
        return { [1] = _player }
    end };
    [2] = { "all,everyone", function(_player)
        return game:GetService("Players"):GetPlayers()
    end };
    [3] = { "others", function(_player)
        local _array, _players = { }, game:GetService("Players"):GetPlayers()
        for _index = 1, #_players do
            if _players[_index] ~= _player then
                _array[#_array + 1] = _players[_index]
            end
        end
        return _array
    end }
}

function TerminalUtil:SplitString(_string, _split)
	local _table, i = { }, 1
	for _str in _string:gmatch("([^" .. _split .. "]+)") do
		_table[i] = _str
		i = i + 1
	end
	return _table
end

function TerminalUtil:Find(_player, _string)
    local _array, _players = { }, game:GetService("Players"):GetPlayers()

    for _index = 1, #Checks do
        local _checkables = TerminalUtil:SplitString(Checks[_index][1], ",")

        for _indexOf = 1, #_checkables do
            if _checkables[_indexOf]:lower() == _string:lower() then
                return Checks[_index][2](_player)
            end
        end
    end

    for _index = 1, #_players do
        if _players[_index].Name:sub(1, #_string):lower() == _string:lower() then
            _array[#_array + 1] = _players[_index]
        end
    end

    return _array
end

function TerminalUtil:FindArray(_player, _array)
    local _newArray = { }

    for _index = 1, #_array do
        ArrayMaid._given = TerminalUtil:Find(_player, _array[_index])
        for _indexOf = 1, #ArrayMaid._given do
            _newArray[#_newArray + 1] = ArrayMaid._given[_indexOf]
        end
        ArrayMaid._given = nil
    end

    return _newArray
end

function TerminalUtil:CheckParsedData(_string)
    return _string:match("%s") and true
end

function TerminalUtil:ReadOnly(_table)
    local _proxy = { }
    local _mt    = {
        __index    = _table;
        __newindex = function(_table, _index, _value)
            error("Attempt to index a read-only table!")
        end;
    }

    setmetatable(_proxy, _mt)

    return _proxy
end

function TerminalUtil:EmulateTabstops(_text, _tabWidth)
    local _result = ""
	for _index = 1, #_text do
		local _char = _text:sub(_index, _index)
		_result = _result .. (_char == "\t" and string.rep(" ", _tabWidth - #_result % _tabWidth) or _char)
    end

	return _result
end

function TerminalUtil:ConvertSeconds(_seconds)
    return string.format("%02i:%02i:%02i", _seconds / 60 ^ 2, _seconds / 60 % 60, _seconds % 60)
end

function TerminalUtil:Start()

    ArrayMaid = Maid.new()

end

function TerminalUtil:Init()

    Maid = self.Shared.Maid

end

return TerminalUtil