function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function countAvailableLevels()
	if not (love and love.filesystem and love.filesystem.getDirectoryItems) then
		return 0
	end

	local ok, files = pcall(love.filesystem.getDirectoryItems, "maps")
	if not ok or type(files) ~= "table" then
		return 0
	end

	local count = 0
	for _, filename in ipairs(files) do
		if filename:match("^level_%d+%.lua$") then
			count = count + 1
		end
	end

	return count
end

function parseColorProperty(value)
	if type(value) ~= "string" then
		return nil
	end

	local hex = value
	hex = hex:gsub("^#", "")
	hex = hex:gsub("^0x", "")
	hex = hex:lower()

	if #hex == 8 then
		local first = {
			tonumber(hex:sub(1, 2), 16),
			tonumber(hex:sub(3, 4), 16),
			tonumber(hex:sub(5, 6), 16),
			tonumber(hex:sub(7, 8), 16),
		}

		if first[1] and first[2] and first[3] and first[4] then
			-- Tiled exports colors in ARGB (#aarrggbb). We also keep compatibility with previous RGBA inputs.
			local useArgb = true
			if (first[1] ~= 255 and first[1] ~= 0) and (first[4] == 255 or first[4] == 0) then
				useArgb = false
			end

			local r, g, b, a
			if useArgb then
				a = first[1]
				r = first[2]
				g = first[3]
				b = first[4]
			else
				r = first[1]
				g = first[2]
				b = first[3]
				a = first[4]
			end

			return {
				r = r / 255,
				g = g / 255,
				b = b / 255,
				a = a / 255,
			}
		end
	elseif #hex == 6 then
		local r = tonumber(hex:sub(1, 2), 16)
		local g = tonumber(hex:sub(3, 4), 16)
		local b = tonumber(hex:sub(5, 6), 16)
		if r and g and b then
			return {
				r = r / 255,
				g = g / 255,
				b = b / 255,
				a = 1.0,
			}
		end
	end

	return nil
end