local M = {}

local function deepCopy(orig, copies)
	if type(orig) ~= "table" then
		return orig
	end

	copies = copies or {}
	if copies[orig] then
		return copies[orig]
	end

	local copy = {}
	copies[orig] = copy

	for orig_key, orig_value in next, orig do
		copy[deepCopy(orig_key, copies)] = deepCopy(orig_value, copies)
	end

	setmetatable(copy, deepCopy(getmetatable(orig), copies))
	return copy
end

M.deepCopy = deepCopy

return M

