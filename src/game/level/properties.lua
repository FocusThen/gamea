local Color = require("src.core.color")

local Properties = {}

function Properties.extract(tiled)
	if not (tiled and tiled.properties) then
		return {
			bgColor = nil,
			mapColor = nil,
		}
	end

	return {
		bgColor = Color.fromHex(tiled.properties.BgColor),
		mapColor = Color.fromHex(tiled.properties.MapColor),
	}
end

return Properties

