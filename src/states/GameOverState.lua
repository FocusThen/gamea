local GameOverState = Class:extend()

function GameOverState:draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.setFont(AM:getFont("large"))
	love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(AM:getFont("medium"))
	love.graphics.printf(
		"Press R to restart or ESC to quit",
		0,
		love.graphics.getHeight() / 2 + 20,
		love.graphics.getWidth(),
		"center"
	)
end


function GameOverState:keypressed(key)
	if key == "r" then
		GSM:setState("game")
	elseif key == "escape" then
		GSM:setState("menu")
	end
end

return GameOverState
