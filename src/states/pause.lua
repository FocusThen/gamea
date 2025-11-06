local pauseScene = Object:extend()
local Constants = require("src.core.constants")
local inputConfig = require("src.systems.inputConfig")
local Colors = require("src.core.colors")
local uiUtils = require("src.ui.utils")
local SettingsScreen = require("src.ui.settingsScreen")

function pauseScene:new()
	self.bindings = inputConfig.createMenuBindings()
	
	-- Menu screens
	self.screens = {
		menu = {
			buttons = {
				{ name = "Resume", action = function() self:resume() end },
				{ name = "Settings", action = function() 
					self.currentScreen = "settings"
					self.settingsScreen.selected = 1
					playSound(sounds.select)
				end },
				{ name = "Level Select", action = function() self:goToLevelSelect() end },
				{ name = "Main Menu", action = function() self:goToMainMenu() end },
			},
			selected = 1,
		},
	}
	
	self.settingsScreen = SettingsScreen()
	self.settingsScreen.onBack = function()
		self.currentScreen = "menu"
		self:saveGame()
		playSound(sounds.select)
	end
	
	self.currentScreen = "menu"
	self.gameStateRef = nil -- Will hold reference to game state for drawing
	self.ignoreInput = true -- Ignore input on first frame to prevent flashing
end

function pauseScene:enter(enterparams)
	-- Store reference to game state so we can draw it behind the pause menu
	self.gameStateRef = enterparams.gameState
	self.currentScreen = "menu"
	self.screens.menu.selected = 1
	self.settingsScreen.selected = 1
	self.ignoreInput = true -- Ignore input on first frame
end

function pauseScene:update(dt)
	self.bindings:update()
	
	-- Ignore input on first frame to prevent the escape key from immediately resuming
	if self.ignoreInput then
		self.ignoreInput = false
		return
	end
	
	local currentScreen = self.screens[self.currentScreen]
	
	if self.currentScreen == "settings" then
		self.settingsScreen:updateNavigation(self.bindings)
	else
		-- Menu screen: simple up/down navigation
		if self.bindings:pressed("up") then
			currentScreen.selected = currentScreen.selected - 1
			playSound(sounds.select)
		elseif self.bindings:pressed("down") then
			currentScreen.selected = currentScreen.selected + 1
			playSound(sounds.select)
		end
		
		-- Clamp selection for menu
		if currentScreen.selected > #currentScreen.buttons then
			currentScreen.selected = 1
		end
		if currentScreen.selected < 1 then
			currentScreen.selected = #currentScreen.buttons
		end
		
		if self.bindings:pressed("select") then
			currentScreen.buttons[currentScreen.selected].action()
		end
	end
	
	if self.bindings:pressed("back") then
		if self.currentScreen == "menu" then
			self:resume()
		else
			self.currentScreen = "menu"
			playSound(sounds.select)
		end
	end
end

function pauseScene:resume()
	playSound(sounds.select)
	-- Instant resume, no transition
	stateMachine:setState("game", { map = self.gameStateRef.map })
end

function pauseScene:goToLevelSelect()
	playSound(sounds.select)
	-- Use transition for going to level select
	sceneEffects:transitionToWithWipe(function()
		stateMachine:setState("levelSelect")
	end)
end

function pauseScene:goToMainMenu()
	playSound(sounds.select)
	-- Save game before going to main menu
	self:saveGame()
	-- Use transition for going to main menu
	sceneEffects:transitionToWithWipe(function()
		stateMachine:setState("main_menu")
	end)
end

function pauseScene:saveGame()
	-- Save game progress and settings
	savedGame.settings = gameSettings
	saveSystem:saveGame()
end

function pauseScene:keypressed(key)
	-- Input is handled in update, but we need this for state machine compatibility
end

function pauseScene:draw()
	-- Draw the game state behind the pause menu
	if self.gameStateRef and self.gameStateRef.draw then
		self.gameStateRef:draw()
	end
	
	-- Draw dark overlay
	love.graphics.setColor(Colors.BACKGROUND[1], Colors.BACKGROUND[2], Colors.BACKGROUND[3], 0.4)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	love.graphics.setColor(1, 1, 1, 1)
	
	-- Draw pause menu
	if self.currentScreen == "menu" then
		self:drawMenuScreen()
	elseif self.currentScreen == "settings" then
		self.settingsScreen:draw()
	end
end

function pauseScene:drawMenuScreen()
	local screen = self.screens.menu
	local yOffset = Constants.MENU.MENU_Y_OFFSET
	local buttonSpacing = Constants.MENU.BUTTON_SPACING
	
	-- Draw buttons
	for i, button in ipairs(screen.buttons) do
		local y = yOffset + (buttonSpacing * (i - 1))
		
		-- Draw selection indicator
		if i == screen.selected then
			love.graphics.setColor(Colors.SELECTION)
			love.graphics.rectangle("fill", 
				gameSettings.gameWidth / 2 - 60, 
				y - 2, 
				120, 
				18
			)
		end
		
		-- Draw button text
		uiUtils.drawCenteredText(button.name, fonts.default, y)
	end
end

return pauseScene

