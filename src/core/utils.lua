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