local titleScene = Object:extend()

function titleScene:new()
	self.bindings = {
		["escape"] = "quit",
	}
end

function titleScene:update(dt) end

function titleScene:draw()
	love.graphics.draw(sprites.ui.title, 0, 0)
end

function titleScene:enter()
	sceneEffects:setWipeOut()
	sceneEffects.wipeTween:oncomplete(function()
		sceneEffects:setWipeIn()
	end)
end

function titleScene:keypressed(k)
	if self.bindings[k] == "quit" then
		love.event.quit()
	else
		sceneEffects:setWipeOut()
		sceneEffects.wipeTween:oncomplete(function()
      stateMachine:setState("game")
			sceneEffects:setWipeIn()
		end)
	end
end

return titleScene
