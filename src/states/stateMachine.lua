local stateMachine = Object:extend()

function stateMachine:new()
	self.states = {}
	self.currentState = nil

	-- Load all game states
	self:loadStates()
end

function stateMachine:loadStates()
	-- Load different game states
	self.states.intro = require("src.states.intro")()
	self.states.main_menu = require("src.states.main_menu")()
	self.states.title = require("src.states.title")() -- Keep for backward compatibility
	self.states.game = require("src.states.game")()
	self.states.levelSelect = require("src.states.levelSelect")()
	self.states.pause = require("src.states.pause")()
	self.states.ending = require("src.states.ending")()
end

function stateMachine:setState(stateName, enterparams)
	if self.states[self.currentState] and self.states[self.currentState].exit then
		self.states[self.currentState]:exit()
	end

	self.currentState = stateName

	if self.states[self.currentState] and self.states[self.currentState].enter then
		self.states[self.currentState]:enter(enterparams)
	end
end

function stateMachine:update(dt)
	if self.states[self.currentState] and self.states[self.currentState].update then
		self.states[self.currentState]:update(dt)
	end
end

function stateMachine:draw()
	if self.states[self.currentState] and self.states[self.currentState].draw then
		self.states[self.currentState]:draw()
	end
end

function stateMachine:keypressed(key)
	if self.states[self.currentState] and self.states[self.currentState].keypressed then
		self.states[self.currentState]:keypressed(key)
	end
end

function stateMachine:keyreleased(key)
	if self.states[self.currentState] and self.states[self.currentState].keyreleased then
		self.states[self.currentState]:keyreleased(key)
	end
end

return stateMachine
