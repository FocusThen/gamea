local gameScene = Object:extend()
local Camera = require("src.camera")
local Constants = require("src.constants")

function gameScene:enter(enterparams)
	self.map = enterparams.map
	self.player = self.map.entities.player
	self.deathTimer = 0
	self.restarting = false
	
	-- Initialize camera
	if not self.camera then
		self.camera = Camera()
	end
	self.camera:setTarget(0, 0) -- Fixed camera for now
	
	-- Store game state reference in triggers for cutscenes
	if self.map.entities.triggers then
		for _, trig in ipairs(self.map.entities.triggers) do
			trig.gameState = self
		end
	end
end

function gameScene:new()
	self.bindings = baton.new({
		controls = {
			reset = { "key:r" },
			pause = { "key:escape", "button:start" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
	self.deathTimer = 0
	self.restarting = false
	self.camera = Camera()
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

	-- Update saws
	if self.map.entities.saws and #self.map.entities.saws > 0 then
		for _, obj in ipairs(self.map.entities.saws) do
			if obj.update then
				obj:update(dt)
			end
		end
	end

	-- Check if player is dead and restart level after delay
	if self.player and self.player.dead and not self.restarting then
		if self.deathTimer == 0 then
			-- Trigger camera shake on death
			self.camera:shake(Constants.CAMERA.DEATH_SHAKE_INTENSITY, Constants.CAMERA.DEATH_SHAKE_DURATION)
		end
		self.deathTimer = self.deathTimer + dt
		if self.deathTimer >= 1.0 then -- 1 second delay
			self.restarting = true
			sceneEffects:transitionToWithWipe(function()
				self.map = loadLevel(self.map.path)
				self.player = self.map.entities.player
				self.deathTimer = 0
				self.restarting = false
			end)
		end
	end
	
	-- Update camera
	if self.camera then
		self.camera:update(dt)
	end

	--------- input ---------
	self.bindings:update()
	if self.bindings:pressed("reset") then
		sceneEffects:transitionToWithWipe(function()
			self.map = loadLevel(self.map.path)
			self.player = self.map.entities.player
			self.deathTimer = 0
			self.restarting = false
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

	-- Apply camera shake
	if self.camera then
		self.camera:apply()
	end

	-- Clear canvas with background color if specified
	if self.map.bgColor then
		love.graphics.clear(self.map.bgColor.r, self.map.bgColor.g, self.map.bgColor.b, self.map.bgColor.a)
	else
		love.graphics.clear()
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
	self:drawObjects(self.map.entities.teleporters)

	-- Apply MapColor shader to platforms, saws, and spikes
	local mapColorApplied = false
	if self.map.mapColor then
		mapColorApplied = shaderSystem:applyColorTint(self.map.mapColor)
	end

	-- Draw platforms (walls) with MapColor shader if available
	self:drawObjects(self.map.entities.platforms)
	
	-- Draw saws with MapColor shader if available
	self:drawObjects(self.map.entities.saws)
	
	-- Draw spikes (deadlyObjects) with MapColor shader if available
	self:drawObjects(self.map.entities.deadlyObjects)

	-- Remove MapColor shader after drawing affected objects
	if mapColorApplied then
		shaderSystem:removeColorTint()
	end

	-- Draw single objects (check if they're actual objects, not empty tables)
	if self.map.entities.door and type(self.map.entities.door) == "table" and self.map.entities.door.draw then
		self.map.entities.door:draw()
	end
	if self.map.entities.player and type(self.map.entities.player) == "table" and self.map.entities.player.draw then
		self.map.entities.player:draw()
	end

	-- Draw particle effects
	particleEffects:draw()
	
	-- Unapply camera shake
	if self.camera then
		self.camera:unapply()
	end
end

return gameScene
