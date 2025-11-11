local sti = require("lib.sti")

local Tiled = {}

function Tiled.load(path)
	return sti("maps/" .. path .. ".lua")
end

return Tiled

