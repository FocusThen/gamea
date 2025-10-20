local player = require("src.objects.player")
local coin = require("src.objects.coin")

function loadLevel(path)
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
	local simple = {
		platforms = {},
		coins = {},
		door = {},
		player = {},
	}

	if tiled.layers["Platforms"] then
		for i, obj in pairs(tiled.layers["Platforms"].objects) do
			simple.platforms[i] =
				{ _id = obj.id, type = "platform", x = obj.x, y = obj.y, width = obj.width, height = obj.height }
			World:add(
				simple.platforms[i],
				simple.platforms[i].x,
				simple.platforms[i].y,
				simple.platforms[i].width,
				simple.platforms[i].height
			)
		end
	end

	-- TODO: in future, refactor
	if tiled.layers["Spawns"] then
		for i, obj in pairs(tiled.layers["Spawns"].objects) do
			if obj.name == "player" then
				-- local playerProp = tiled:getObjectProperties("Spawns", "player")
				simple.player = player(obj.x, obj.y)
			elseif obj.name == "coin" then
				-- local coinProp = tiled:getObjectProperties("Spawns", "coin")
				table.insert(simple.coins, coin(obj.x, obj.y))
			elseif obj.name == "door" then
				-- local doorProp = tiled:getObjectProperties("Spawns", "door")
				simple.door = {} -- create door
			end
		end
	end

	local function drawWorld()
		if tiled.layers["Bg"] then
			tiled:drawLayer(tiled.layers["Bg"])
		end

		for key, value in pairs(simple) do
			if key == "platform" then
				if #value > 0 then
					for _, obj in ipairs(value) do
						obj:draw()
					end
				end
			elseif key == "coins" then
				if #value > 0 then
					for _, obj in ipairs(value) do
						obj:draw()
					end
				end
			-- elseif key == "door" then
			-- 	value:draw()
			elseif key == "player" then
				value:draw()
			end
		end
	end

	local function updateWorld(dt)
		if #simple.coins > 0 then
			for _, obj in ipairs(simple.coins) do
				obj:update(dt)
			end
		end

		for i = #simple.coins, 1, -1 do
			if simple.coins[i].delete then
				table.remove(simple.coins, i)
			end
		end
	end

	return {
		tiled = tiled,
		simple = simple,
		drawWorld = drawWorld,
		updateWorld = updateWorld,
	}
end
