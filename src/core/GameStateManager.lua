local GameStateManager = Class:extend()

function GameStateManager:new()
	self.states = {}
	self.currentState = nil

	-- Load all game states
	self:loadStates()
end

function GameStateManager:loadStates()
	-- Load different game states
	self.states.menu = require("src.states.MenuState")()
	self.states.game = require("src.states.GameState")()
	self.states.pause = require("src.states.PauseState")()
	self.states.gameover = require("src.states.GameOverState")()
end

function GameStateManager:setState(stateName)
	if self.states[self.currentState] and self.states[self.currentState].exit then
		self.states[self.currentState]:exit()
	end

	self.currentState = stateName

	if self.states[self.currentState] and self.states[self.currentState].enter then
		self.states[self.currentState]:enter()
	end
end

function GameStateManager:update(dt)
	if self.states[self.currentState] and self.states[self.currentState].update then
		self.states[self.currentState]:update(dt)
	end
end

function GameStateManager:draw()
	if self.states[self.currentState] and self.states[self.currentState].draw then
		self.states[self.currentState]:draw()
	end
end

function GameStateManager:keypressed(key)
	if self.states[self.currentState] and self.states[self.currentState].keypressed then
		self.states[self.currentState]:keypressed(key)
	end
end

function GameStateManager:keyreleased(key)
	if self.states[self.currentState] and self.states[self.currentState].keyreleased then
		self.states[self.currentState]:keyreleased(key)
	end
end

return GameStateManager
