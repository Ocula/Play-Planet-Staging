--[[
	@Author: Anna W. <https://devforum.roblox.com/u/ImActuallyAnna> Skylar L. <https://devforum.roblox.com/u/ScobayDu>
	@Description: Base64 encoding/decoding utility
	@Date of Creation: 10. 05. 2020
	
	Copyright (C) 2020 Kat Digital Limited.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License v3.0 as published by
	the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

local Base64 = {}

--Characters to perform encoding
local CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--Function to encode a string in Base64
function Base64.encode(str)
	--Get length and pre-allocate output array
	local len = #str
	local base64 = {}

	--We create a bit output 'stream' and write a Base64 character
	--to the output buffer if it contains more than 6 bits. We use these
	--characters to keep track of that information.
	local tempBits, nBits = 0, 0
	for i = 1, len do
		local byte = string.byte(str, i, i)

		--Write 8 bits to the output bit stream
		tempBits = 256 * tempBits + byte
		nBits = nBits + 8

		--Write Base64 characters until there are less than 6 remaining bits
		while nBits >= 6 do
			--Get 6 most significant bits
			local factor = math.pow(2, nBits - 6)
			local value = math.floor(tempBits / factor) + 1
			table.insert(base64, CHARACTERS:sub(value, value))

			tempBits = tempBits % factor
			nBits = nBits - 6
		end
	end

	--There may be a final character to encode
	if nBits > 0 then
		--Shift the remaining bits to start at the beginning of the
		--next 6 bit
		local value = tempBits * math.pow(2, 6 - nBits) + 1
		table.insert(base64, CHARACTERS:sub(value, value))
	end

	--Pad the string length to a multiple of 4
	if #base64 % 4 ~= 0 then
		for i = #base64 % 4, 3 do
			table.insert(base64, "=")
		end
	end

	return table.concat(base64)
end

--Function to decode a Base64-encoded string
--Function to encode a string in Base64
function Base64.decode(str)
	--Get length and pre-allocate output array
	local len = #str
	local ascii = {}

	--We create a bit output 'stream' and write an ASCII character
	--to the output buffer if it contains more than 8 bits. We use these
	--characters to keep track of that information.
	local tempBits, nBits = 0, 0
	for i = 1, len do
		local chr = str:sub(i, i)
		local bits

		--We read a "=" character as a 0 when writing to the bit output stream
		if chr ~= "=" then
			bits = CHARACTERS:find(chr) - 1
		else
			bits = 0
		end

		--Write 6 bits to the output
		tempBits = 64 * tempBits + bits
		nBits = nBits + 6

		--Write bytes until there are no full bytes left
		while nBits >= 8 do
			--Get 8 most significant bits
			local factor = math.pow(2, nBits - 8)
			local value = math.floor(tempBits / factor)
			table.insert(ascii, string.char(value))

			tempBits = tempBits % factor
			nBits = nBits - 8
		end
	end

	return table.concat(ascii)
end

return Base64
