local titleScene = Object:extend()

local inputConfig = require("src.systems.inputConfig")

function titleScene:new()
	self.bindings = inputConfig.createSimpleBindings({
		quit = { "key:escape", "button:b" },
		continue = {
			"key:space",
			"key:return",
			"key:z",
			"button:a",
		},
	})
end

function titleScene:update(dt)
	--------- input ---------
	self.bindings:update()
	if self.bindings:pressed("quit") then
		love.event.quit()
	elseif self.bindings:pressed("continue") then
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("levelSelect")
		end)
	end
end

function titleScene:draw()
	-- love.graphics.draw(sprites.ui.title, 0, 0)
end

function titleScene:enter()
	sceneEffects:setFadeIn()
end

return titleScene
