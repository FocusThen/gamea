local player = require("src.objects.player")
local coin = require("src.objects.coin")
local door = require("src.objects.door")
local box = require("src.objects.box")
local trigger = require("src.objects.trigger")

function loadLevel(path)
	-- destroy all objects
	local items, len = World:getItems()
	for i = 1, len do
		local item = items[i]
		World:remove(item)
	end
	---
	---
	local number = tonumber(string.match(path, "%d+"))
	if number and savedGame.levelReached < number then
		savedGame.levelReached = number
	end
	---

	local slide, cross = bump.responses.slide, bump.responses.cross
	local oneWay = function(wrld, col, x, y, w, h, goalX, goalY, filter)
		if col.normal.y < 0 and not col.overlaps then
			col.didTouch = true
			return slide(wrld, col, x, y, w, h, goalX, goalY, filter)
		else
			return cross(wrld, col, x, y, w, h, goalX, goalY, filter)
		end
	end

	World:addResponse("oneWay", oneWay)

	local tiled = sti("maps/" .. path .. ".lua")
	local entities = {
		platforms = {},
		coins = {},
		boxes = {},
		door = {},
		player = {},
		triggers = {},
	}
	-- Entity lookup by ID for triggers
	local entitiesById = {}

	if tiled.layers["Platforms"] then
		for i, obj in pairs(tiled.layers["Platforms"].objects) do
			entities.platforms[i] =
				{ _id = obj.id, type = "platform", x = obj.x, y = obj.y, width = obj.width, height = obj.height }
			entitiesById[obj.id] = entities.platforms[i]
			World:add(
				entities.platforms[i],
				entities.platforms[i].x,
				entities.platforms[i].y,
				entities.platforms[i].width,
				entities.platforms[i].height
			)
		end
	end

	if tiled.layers["Dangers"] then
		for i, obj in pairs(tiled.layers["Dangers"].objects) do
			if obj.name == "spike" then
				-- local spikeProp = tiled:getObjectProperties("Dangers", "spike")
				local spike = {
					x = obj.x,
					y = obj.y,
					width = obj.width,
					height = obj.height,
					type = "spike",
					interact = function(self, player)
						player:kill()
					end,
				}
				World:add(spike, spike.x, spike.y, spike.width, spike.height)
			end
		end
	end

	-- Load spawn objects and store by ID
	if tiled.layers["Spawns"] then
		for i, obj in pairs(tiled.layers["Spawns"].objects) do
			if obj.name == "player" then
				local playerProp = tiled:getObjectProperties("Spawns", "player")
				entities.player = player(obj.x, obj.y, playerProp)
				entitiesById[obj.id] = entities.player
			elseif obj.name == "coin" then
				local coinObj = coin(obj.x, obj.y)
				coinObj._id = obj.id
				table.insert(entities.coins, coinObj)
				entitiesById[obj.id] = coinObj
			elseif obj.name == "box" then
				local boxObj = box(obj.x, obj.y)
				boxObj._id = obj.id
				table.insert(entities.boxes, boxObj)
				entitiesById[obj.id] = boxObj
			elseif obj.name == "door" then
				entities.door = door(obj.x, obj.y, path)
				entities.door._id = obj.id
				entitiesById[obj.id] = entities.door
			elseif obj.name == "trigger" then
				local triggerProp = tiled:getObjectProperties("Spawns", "trigger")
				if triggerProp == nil or triggerProp == {} then
					triggerProp = obj.properties or {}
				end
				-- Handle targetId from Tiled (can be object reference {id = X})
				if triggerProp.targetId and type(triggerProp.targetId) == "table" and triggerProp.targetId.id then
					triggerProp.targetId = triggerProp.targetId.id
				end
				local triggerObj = trigger(obj.x, obj.y, triggerProp)
				triggerObj._id = obj.id
				table.insert(entities.triggers, triggerObj)
				entitiesById[obj.id] = triggerObj
			end
		end
	end

	-- Link triggers to targets by ID
	for _, trig in ipairs(entities.triggers) do
		if trig.targetId then
			local targetId = trig.targetId
			-- Handle both number and table format from Tiled
			if type(targetId) == "table" and targetId.id then
				targetId = targetId.id
			end
			if entitiesById[targetId] then
				trig.target = entitiesById[targetId]
			end
		end
	end

	return {
		tiled = tiled,
		entities = entities,
		path = path,
	}
end
