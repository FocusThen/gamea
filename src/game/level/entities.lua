local player = require("src.objects.player")
local coin = require("src.objects.coin")
local door = require("src.objects.door")
local box = require("src.objects.box")
local trigger = require("src.objects.trigger")
local saw = require("src.objects.saw")
local teleporter = require("src.objects.teleporter")

local Entities = {}

local function newContext(world, path)
	return {
		world = world,
		path = path,
		entities = {
			platforms = {},
			coins = {},
			boxes = {},
			door = {},
			player = {},
			triggers = {},
			saws = {},
			teleporters = {},
			deadlyObjects = {},
		},
		byId = {},
	}
end

function Entities.resetWorld(world)
	local items, len = world:getItems()
	for i = 1, len do
		world:remove(items[i])
	end
end

function Entities.configureResponses(world)
	local slide, cross = bump.responses.slide, bump.responses.cross
	local function oneWay(_, col, x, y, w, h, goalX, goalY, filter)
		if col.normal.y < 0 and not col.overlaps then
			col.didTouch = true
			return slide(world, col, x, y, w, h, goalX, goalY, filter)
		end
		return cross(world, col, x, y, w, h, goalX, goalY, filter)
	end

	world:addResponse("oneWay", oneWay)
end

local function register(context, entity, id, collection, index)
	if id then
		entity._id = id
		context.byId[id] = entity
	end

	if not collection then
		return
	end

	if index then
		collection[index] = entity
	else
		table.insert(collection, entity)
	end
end

local function addPlatform(context, index, obj)
	local entity = {
		_id = obj.id,
		type = "platform",
		x = obj.x,
		y = obj.y,
		width = obj.width,
		height = obj.height,
	}

	entity.draw = function(self)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end

	register(context, entity, obj.id, context.entities.platforms, index)
	context.world:add(entity, entity.x, entity.y, entity.width, entity.height)
end

local function addSpike(context, obj)
	local spike = {
		x = obj.x,
		y = obj.y,
		width = obj.width,
		height = obj.height,
		type = "spike",
		interact = function(self, target)
			target:kill()
		end,
	}

	spike.draw = function(self)
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end

	context.world:add(spike, spike.x, spike.y, spike.width, spike.height)
	table.insert(context.entities.deadlyObjects, spike)
	context.byId[obj.id] = spike
end

local function addDeadlyObject(context, obj)
	local deadlyObject = {
		x = obj.x,
		y = obj.y,
		width = obj.width,
		height = obj.height,
		type = "deadlyObject",
		interact = function(self, target)
			target:kill()
		end,
		draw = function()
			-- Invisible kill zone
		end,
	}

	context.world:add(deadlyObject, deadlyObject.x, deadlyObject.y, deadlyObject.width, deadlyObject.height)
	table.insert(context.entities.deadlyObjects, deadlyObject)
	context.byId[obj.id] = deadlyObject
end

local function handleDangers(context, layer)
	for _, obj in pairs(layer.objects) do
		if obj.name == "spike" then
			addSpike(context, obj)
		elseif obj.name == "saw" then
			local sawObj = saw(obj.x, obj.y, obj.properties or {})
			sawObj._id = obj.id
			table.insert(context.entities.saws, sawObj)
			context.byId[obj.id] = sawObj
		elseif obj.name == "deadlyObject" then
			addDeadlyObject(context, obj)
		end
	end
end

local function normaliseTargetId(targetId)
	if type(targetId) == "table" and targetId.id then
		return targetId.id
	end
	return targetId
end

local function handleTrigger(context, obj)
	local triggerProp = obj.properties or {}
	triggerProp.targetId = normaliseTargetId(triggerProp.targetId)

	local triggerObj = trigger(obj.x, obj.y, obj.width, obj.height, triggerProp)
	triggerObj._id = obj.id
	triggerObj.map = { entitiesById = context.byId }

	table.insert(context.entities.triggers, triggerObj)
	context.byId[obj.id] = triggerObj
end

local function handleTeleporter(context, obj)
	local teleporterProp = obj.properties or {}
	teleporterProp.targetId = normaliseTargetId(teleporterProp.targetId)

	local teleporterObj = teleporter(obj.x, obj.y, teleporterProp)
	teleporterObj._id = obj.id

	table.insert(context.entities.teleporters, teleporterObj)
	context.byId[obj.id] = teleporterObj
end

local function handleSpawns(context, tiled, layer)
	for _, obj in pairs(layer.objects) do
		if obj.name == "player" then
			local playerProp = tiled:getObjectProperties("Spawns", "player")
			context.entities.player = player(obj.x, obj.y, playerProp)
			context.byId[obj.id] = context.entities.player
		elseif obj.name == "coin" then
			local coinObj = coin(obj.x, obj.y)
			register(context, coinObj, obj.id, context.entities.coins)
		elseif obj.name == "box" then
			local boxObj = box(obj.x, obj.y)
			register(context, boxObj, obj.id, context.entities.boxes)
		elseif obj.name == "door" then
			local doorObj = door(obj.x, obj.y, context.path)
			doorObj._id = obj.id
			context.entities.door = doorObj
			context.byId[obj.id] = doorObj
		elseif obj.name == "trigger" then
			handleTrigger(context, obj)
		elseif obj.name == "teleporter" then
			handleTeleporter(context, obj)
		end
	end
end

local function linkTargets(collection, byId)
	for _, obj in ipairs(collection) do
		if obj.targetId then
			local targetId = normaliseTargetId(obj.targetId)
			obj.target = byId[targetId]
		end
	end
end

local function addKillZones(context, tiled)
	local mapWidth = tiled.width * tiled.tilewidth
	local mapHeight = tiled.height * tiled.tileheight
	local killZoneSize = 1000

	local bottomKillZone = {
		x = 0,
		y = mapHeight,
		width = mapWidth,
		height = killZoneSize,
		type = "deadlyObject",
		interact = function(self, target)
			target:kill()
		end,
		draw = function()
			-- Invisible kill zone
		end,
	}

	context.world:add(bottomKillZone, bottomKillZone.x, bottomKillZone.y, bottomKillZone.width, bottomKillZone.height)
	table.insert(context.entities.deadlyObjects, bottomKillZone)
end

function Entities.build(world, tiled, path)
	local context = newContext(world, path)

	if tiled.layers["Platforms"] then
		for index, obj in pairs(tiled.layers["Platforms"].objects) do
			addPlatform(context, index, obj)
		end
	end

	if tiled.layers["Dangers"] then
		handleDangers(context, tiled.layers["Dangers"])
	end

	if tiled.layers["Spawns"] then
		handleSpawns(context, tiled, tiled.layers["Spawns"])
	end

	linkTargets(context.entities.triggers, context.byId)
	linkTargets(context.entities.teleporters, context.byId)

	addKillZones(context, tiled)

	return context.entities
end

return Entities

