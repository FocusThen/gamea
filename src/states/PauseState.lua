local PauseState = Class:extend()

function PauseState:update(dt)
	-- Don't update game entities while paused
end

function PauseState:draw()
	-- Draw the game state behind the pause overlay
	GSM.states.game:draw()

	-- Draw pause overlay
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(AM:getFont("large"))
	love.graphics.printf("PAUSED", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
	love.graphics.setFont(AM:getFont("medium"))
	love.graphics.printf("Press P to resume", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
end

function PauseState:keypressed(key)
	if key == "p" or key == "escape" then
		GSM:setState("game")
	end
end

return PauseState
