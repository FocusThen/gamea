local M = {}

local function safeDirectoryItems(path)
	if not (love and love.filesystem and love.filesystem.getDirectoryItems) then
		return {}
	end

	local ok, items = pcall(love.filesystem.getDirectoryItems, path)
	if not ok or type(items) ~= "table" then
		return {}
	end

	return items
end

function M.countPattern(path, pattern)
	local items = safeDirectoryItems(path)
	local count = 0

	for _, filename in ipairs(items) do
		if filename:match(pattern) then
			count = count + 1
		end
	end

	return count
end

function M.countLevels()
	return M.countPattern("maps", "^level_%d+%.lua$")
end

return M

