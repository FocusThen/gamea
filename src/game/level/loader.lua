local Tiled = require("src.game.level.tiled")
local Entities = require("src.game.level.entities")
local Properties = require("src.game.level.properties")

local Loader = {}

local function updateProgress(path)
	local number = tonumber(string.match(path, "%d+"))
	if number and savedGame.levelReached < number then
		savedGame.levelReached = number
	end
end

function Loader.load(path)
	Entities.resetWorld(World)
	Entities.configureResponses(World)
	updateProgress(path)

	local tiled = Tiled.load(path)
	local entities = Entities.build(World, tiled, path)
	local props = Properties.extract(tiled)

	return {
		tiled = tiled,
		entities = entities,
		path = path,
		bgColor = props.bgColor,
		mapColor = props.mapColor,
	}
end

return Loader

