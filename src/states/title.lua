local titleScene = Object:extend()

function titleScene:new()
	self.bindings = baton.new({
		controls = {
			quit = { "key:escape", "button:b" }, -- Back/Start buttons
			continue = {
				"key:space",
				"key:return",
				"key:z",
				"button:a", -- A button (Xbox), Cross (PS)
			},
		},
		joystick = love.joystick.getJoysticks()[1],
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
