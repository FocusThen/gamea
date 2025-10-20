local gameScene = Object:extend()

function gameScene:enter(enterparams)
	self.map = enterparams.map
	self.player = self.map.simple.player
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
	--------- input ---------
	self.bindings:update()
	-- if self.bindings:pressed("pause") then
	-- love.event.quit()
	-- end
end

function gameScene:draw()
	--- game draw codes
	self.map.drawWorld()

	---
	particleEffects:draw()
	---
end

return gameScene
