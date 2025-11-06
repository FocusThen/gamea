local mainMenuScene = Object:extend()
local Constants = require("src.core.constants")
local inputConfig = require("src.systems.inputConfig")
local Colors = require("src.core.colors")
local uiUtils = require("src.ui.utils")
local SettingsScreen = require("src.ui.settingsScreen")

function mainMenuScene:new()
	self.bindings = inputConfig.createMenuBindings()

	-- Save check will be done in enter()
	self.hasSave = false
	self.settingsScreen = SettingsScreen()
	self.settingsScreen.onBack = function()
		self.currentScreen = "menu"
		self:saveSettings()
		playSound(sounds.select)
	end
end

function mainMenuScene:buildMenu()
	local buttons = {}

	-- Add Continue option if save exists
	if self.hasSave then
		table.insert(buttons, {
			name = "Continue",
			action = function()
				playSound(sounds.select)
				sceneEffects:transitionToWithWipe(function()
					saveSystem:loadGame()
					local levelPath = "level_" .. savedGame.levelReached
					stateMachine:setState("game", { map = loadLevel(levelPath) })
				end)
			end,
		})
	end

	-- Always show New Game
	table.insert(buttons, {
		name = "New Game",
		action = function()
			playSound(sounds.select)
			sceneEffects:transitionToWithWipe(function()
				-- Reset save
				savedGame.levelReached = 1
				saveSystem:deleteSave()
				stateMachine:setState("levelSelect")
			end)
		end,
	})

	-- Settings
	table.insert(buttons, {
		name = "Settings",
		action = function()
			playSound(sounds.select)
			self.currentScreen = "settings"
			self.settingsScreen.selected = 1
		end,
	})

	-- Quit
	table.insert(buttons, {
		name = "Quit",
		action = function()
			playSound(sounds.select)
			love.event.quit()
		end,
	})

	-- Menu screen
	if not self.screens then
		self.screens = {
			menu = {
				buttons = buttons,
				selected = 1,
			},
		}
	else
		self.screens.menu.buttons = buttons
	end

	self.currentScreen = "menu"
end

function mainMenuScene:enter()
	-- Check if save exists (now saveSystem is initialized)
	if saveSystem then
		self.hasSave = saveSystem:hasSave()
	else
		self.hasSave = false
	end
	self:buildMenu()
	self.currentScreen = "menu"
	sceneEffects:setFadeIn()
end

function mainMenuScene:update(dt)
	self.bindings:update()

	if self.currentScreen == "menu" then
		local screen = self.screens.menu
		if self.bindings:pressed("up") then
			screen.selected = screen.selected - 1
			if screen.selected < 1 then
				screen.selected = #screen.buttons
			end
			playSound(sounds.select)
		elseif self.bindings:pressed("down") then
			screen.selected = screen.selected + 1
			if screen.selected > #screen.buttons then
				screen.selected = 1
			end
			playSound(sounds.select)
		end

		if self.bindings:pressed("select") then
			local button = screen.buttons[screen.selected]
			if button and button.action and not button.disabled then
				button.action()
			end
		end

		if self.bindings:pressed("quit") then
			love.event.quit()
		end
	elseif self.currentScreen == "settings" then
		self.settingsScreen:updateNavigation(self.bindings)
		
		if self.bindings:pressed("quit") then
			self.currentScreen = "menu"
			self:saveSettings()
			playSound(sounds.select)
		end
	end
end

function mainMenuScene:saveSettings()
	savedGame.settings = gameSettings
	saveSystem:saveGame()
end

function mainMenuScene:draw()
	-- Draw background
	uiUtils.drawBackground()

	-- Draw menu
	if self.currentScreen == "menu" then
		self:drawMenuScreen()
	elseif self.currentScreen == "settings" then
		self.settingsScreen:draw()
	end
end

function mainMenuScene:drawMenuScreen()
	local screen = self.screens.menu
	local yOffset = Constants.MENU.MENU_Y_OFFSET
	local buttonSpacing = Constants.MENU.BUTTON_SPACING

	-- Draw buttons
	for i, button in ipairs(screen.buttons) do
		local y = yOffset + (buttonSpacing * (i - 1))

		-- Draw selection indicator
		if i == screen.selected then
			love.graphics.setColor(Colors.SELECTION)
			love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - 60, y - 2, 120, 18)
		end

		-- Draw button text
		local textColor = button.disabled and Colors.GREY or Colors.WHITE
		uiUtils.drawCenteredText(button.name, fonts.default, y, textColor)
	end
end


return mainMenuScene
