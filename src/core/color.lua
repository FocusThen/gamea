local clamp = math.max

local function channelFromHex(segment)
	local value = tonumber(segment, 16)
	if not value then
		return nil
	end
	return value / 255
end

local function channelToHex(value)
	local clamped = clamp(0, math.min(1, value or 0))
	return string.format("%02x", math.floor(clamped * 255 + 0.5))
end

local M = {}

---Convert a hexadecimal string to a colour table.
-- Supports formats: #AARRGGBB (Tiled default) and #RRGGBB.
-- @param hex string
-- @return table|nil {r, g, b, a}
function M.fromHex(hex)
	if type(hex) ~= "string" then
		return nil
	end

	local value = hex:gsub("#", "")

	if #value == 8 then
		local a = channelFromHex(value:sub(1, 2))
		local r = channelFromHex(value:sub(3, 4))
		local g = channelFromHex(value:sub(5, 6))
		local b = channelFromHex(value:sub(7, 8))

		if r and g and b and a then
			return { r = r, g = g, b = b, a = a }
		end
	elseif #value == 6 then
		local r = channelFromHex(value:sub(1, 2))
		local g = channelFromHex(value:sub(3, 4))
		local b = channelFromHex(value:sub(5, 6))
		if r and g and b then
			return { r = r, g = g, b = b, a = 1 }
		end
	end

	return nil
end

---Convert a colour table to #AARRGGBB hex string.
-- @param color table {r, g, b, a}
-- @return string
function M.toHex(color)
	if type(color) ~= "table" then
		return nil
	end

	local a = channelToHex(color.a)
	local r = channelToHex(color.r)
	local g = channelToHex(color.g)
	local b = channelToHex(color.b)

	return "#" .. a .. r .. g .. b
end

return M

