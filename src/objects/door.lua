local door = Object:extend()

local Constants = require("src.core.constants")

function door:new(x, y, currentLevel)
	self.x = x
	self.y = y
	self.width = Constants.DOOR.WIDTH
	self.height = Constants.DOOR.HEIGHT
	self.type = "door"
	self.currentLevel = currentLevel

	World:add(self, self.x, self.y, self.width, self.height)
end

function door:draw()
	love.graphics.setColor(0, 1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)
end

function door:interact(player)
	-- Player parameter is accepted but not currently used
	local number = tonumber(string.match(self.currentLevel, "%d+"))
	local nextLevel = "level_" .. (number + 1)

	sceneEffects:transitionToWithWipe(function()
		if number == numOfLevels then
			-- Save game and go to ending
			saveSystem:saveGame()
			stateMachine:setState("ending")
		else
			-- Auto-save on level completion
			saveSystem:saveGame()
			stateMachine:setState("game", { map = loadLevel(nextLevel) })
		end
	end)
	-- playSound(sounds.ending)
end

return door
