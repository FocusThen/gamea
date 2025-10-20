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

	--- Coins
	if #self.map.simple.coins > 0 then
		for _, obj in ipairs(self.map.simple.coins) do
			obj:update(dt)
		end
	end

	for i = #self.map.simple.coins, 1, -1 do
		if self.map.simple.coins[i].delete then
			table.remove(self.map.simple.coins, i)
		end
	end
	---

	--------- input ---------
	self.bindings:update()
	if self.bindings:pressed("reset") then
		sceneEffects:transitionToWithWipe(function()
			self.map = loadLevel(self.map.path)
			self.player = self.map.simple.player
		end)
	end
end

function gameScene:draw()
	--- game draw codes
	if self.map.tiled.layers["Bg"] then
		self.map.tiled:drawLayer(self.map.tiled.layers["Bg"])
	end

	for key, value in pairs(self.map.simple) do
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
		elseif key == "door" then
			value:draw()
		elseif key == "player" then
			value:draw()
		end
	end

	---
	particleEffects:draw()
	---
end

return gameScene
