local MenuState = Class:extend()

function MenuState:new()
	self.selectedOption = 1
	self.options = { "Start Game", "Settings", "Quit" }
end

function MenuState:update(dt)
	-- Menu update logic
end

function MenuState:draw()
	love.graphics.setFont(AM:getFont("large"))
	love.graphics.printf("GAME TEMPLATE", 0, 200, love.graphics.getWidth(), "center")

	love.graphics.setFont(AM:getFont("medium"))
	for i, option in ipairs(self.options) do
		local color = i == self.selectedOption and { 1, 1, 0 } or { 1, 1, 1 }
		love.graphics.setColor(color)
		love.graphics.printf(option, 0, 300 + i * 40, love.graphics.getWidth(), "center")
	end
	love.graphics.setColor(1, 1, 1)
end

function MenuState:keypressed(key)
	if key == "up" then
		self.selectedOption = math.max(1, self.selectedOption - 1)
	elseif key == "down" then
		self.selectedOption = math.min(#self.options, self.selectedOption + 1)
	elseif key == "return" or key == "space" then
		if self.selectedOption == 1 then
			GSM:setState("game")
		elseif self.selectedOption == 3 then
			love.event.quit()
		end
	end
end

return MenuState
