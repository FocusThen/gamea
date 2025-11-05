local gameScene = Object:extend()

function gameScene:enter(enterparams)
	self.map = enterparams.map
	self.player = self.map.entities.player
end

function gameScene:new()
	self.bindings = baton.new({
		controls = {
			reset = { "key:r" },
			pause = { "key:escape", "button:start" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
end

function gameScene:update(dt)
	self.player:update(dt)
	particleEffects:update(dt)

	-- Update boxes
	if self.map.entities.boxes and #self.map.entities.boxes > 0 then
		for _, obj in ipairs(self.map.entities.boxes) do
			obj:update(dt)
		end
	end

	-- Update coins
	if self.map.entities.coins and #self.map.entities.coins > 0 then
		for _, obj in ipairs(self.map.entities.coins) do
			obj:update(dt)
		end
		-- Remove deleted coins
		for i = #self.map.entities.coins, 1, -1 do
			if self.map.entities.coins[i].delete then
				table.remove(self.map.entities.coins, i)
			end
		end
	end

	-- Update triggers (for smooth movement)
	if self.map.entities.triggers and #self.map.entities.triggers > 0 then
		for _, obj in ipairs(self.map.entities.triggers) do
			if obj.update then
				obj:update(dt)
			end
		end
	end

	--------- input ---------
	self.bindings:update()
	if self.bindings:pressed("reset") then
		sceneEffects:transitionToWithWipe(function()
			self.map = loadLevel(self.map.path)
			self.player = self.map.entities.player
		end)
	elseif self.bindings:pressed("pause") then
		-- Instant pause, no transition
		stateMachine:setState("pause", { gameState = self })
	end
end

function gameScene:drawObjects(objects)
	if objects then
		-- Check if it's an array (has length) or hash table
		if type(objects) == "table" then
			-- Try array iteration first
			if #objects > 0 then
				for _, obj in ipairs(objects) do
					if obj and obj.draw then
						obj:draw()
					end
				end
			else
				-- Fall back to pairs for hash tables
				for _, obj in pairs(objects) do
					if obj and obj.draw then
						obj:draw()
					end
				end
			end
		end
	end
end

function gameScene:draw()
	if not self.map or not self.map.entities then
		return
	end

	-- Draw background layer
	if self.map.tiled and self.map.tiled.layers and self.map.tiled.layers["Bg"] then
		self.map.tiled:drawLayer(self.map.tiled.layers["Bg"])
	end

	-- Draw game objects (platforms are collision-only, not drawn)
	-- Only draw objects that have a draw method
	self:drawObjects(self.map.entities.coins)
	self:drawObjects(self.map.entities.boxes)
	self:drawObjects(self.map.entities.triggers)

	-- Draw single objects (check if they're actual objects, not empty tables)
	if self.map.entities.door and type(self.map.entities.door) == "table" and self.map.entities.door.draw then
		self.map.entities.door:draw()
	end
	if self.map.entities.player and type(self.map.entities.player) == "table" and self.map.entities.player.draw then
		self.map.entities.player:draw()
	end

	-- Draw particle effects
	particleEffects:draw()
end

return gameScene
