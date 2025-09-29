local GameState = Class:extend()

function GameState:new()
	self.camera = nil
	self.map = nil
	self.player = nil
end

function GameState:enter()
	self.camera = Camera()

	-- Clear any existing entities
	EM:clear()

	-- Load level/map if using STI
	-- self.map = sti("assets/maps/level1.lua")

	-- Create player
	local Player = require("src.entities.Player")
	self.player = Player(100, 100)
	EM:addEntity(self.player)

	-- Create some test entities
	self:createTestLevel()

	if self.player then
		self.camera:lookAt(self.player.x + self.player.w / 2, self.player.y + self.player.h / 2)
	end
end

function GameState:createTestLevel()
	local Ground = require("src.entities.Ground")
	local Pickup = require("src.entities.Pickup")

	-- Create ground
	EM:addEntity(Ground(0, 500, 800, 100))
	EM:addEntity(Ground(200, 440, 150, 20, "platform")) -- Platform

	-- Create pickups
	EM:addEntity(Pickup(200, 300))
	EM:addEntity(Pickup(300, 470))
	EM:addEntity(Pickup(350, 470))
	EM:addEntity(Pickup(400, 440, "fake"))
	EM:addEntity(Pickup(450, 470))
end

function GameState:update(dt)
	-- Update camera to follow player
	if self.player then
		self.camera:lookAt(self.player.x + self.player.w / 2, self.player.y + self.player.h / 2)
	end

	-- Update map if using STI
	if self.map then
		self.map:update(dt)
	end
end

function GameState:draw()
	self.camera:attach()

	-- Draw map if using STI
	if self.map then
		self.map:draw()
	end

	-- Draw all entities
	EM:draw()

	self.camera:detach()

	-- Draw UI (not affected by camera)
	self:drawUI()
end

function GameState:drawUI()
	love.graphics.setFont(AM:getFont("medium"))
	love.graphics.print("Game State - Use WASD/Arrow Keys + Space", 10, 10)
	love.graphics.print("ESC: Quit, P: Pause", 10, 30)
end

function GameState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "p" then
		GSM:setState("pause")
	elseif key == "r" then
		self:enter()
	end
end

function GameState:exit()
	-- Cleanup when leaving state
end

return GameState
