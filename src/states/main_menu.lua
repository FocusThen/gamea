local mainMenuScene = Object:extend()
local Constants = require("src.constants")

function mainMenuScene:new()
	self.bindings = baton.new({
		controls = {
			up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
			down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
			left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
			right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
			select = { "key:space", "key:return", "key:z", "button:a" },
			quit = { "key:escape", "button:b" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})

	-- Save check will be done in enter()
	self.hasSave = false
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
			self.screens.settings.selected = 1
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

	-- Settings menu (similar to pause menu settings)
	if not self.screens then
		self.screens = {
			menu = {
				buttons = buttons,
				selected = 1,
			},
			settings = {
				buttons = {
					{
						name = "Master Vol +",
						action = function()
							self:adjustVolume("master", 1)
						end,
					},
					{
						name = "Master Vol -",
						action = function()
							self:adjustVolume("master", -1)
						end,
					},
					{
						name = "Music Vol +",
						action = function()
							self:adjustVolume("music", 1)
						end,
					},
					{
						name = "Music Vol -",
						action = function()
							self:adjustVolume("music", -1)
						end,
					},
					{
						name = "SFX Vol +",
						action = function()
							self:adjustVolume("sfx", 1)
						end,
					},
					{
						name = "SFX Vol -",
						action = function()
							self:adjustVolume("sfx", -1)
						end,
					},
					{
						name = "CRT Shader",
						action = function()
							shaderSystem:toggle("crt")
							playSound(sounds.select)
						end,
					},
					{
						name = "Back",
						action = function()
							self.currentScreen = "menu"
							self:saveSettings()
							playSound(sounds.select)
						end,
					},
				},
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
		local screen = self.screens.settings
		local maxSelection = #screen.buttons

		if self.bindings:pressed("up") then
			screen.selected = screen.selected - 1
			if screen.selected < 1 then
				screen.selected = maxSelection
			end
			playSound(sounds.select)
		elseif self.bindings:pressed("down") then
			screen.selected = screen.selected + 1
			if screen.selected > maxSelection then
				screen.selected = 1
			end
			playSound(sounds.select)
		elseif self.bindings:pressed("left") then
			-- Navigate between volume controls (paired +/- buttons)
			if screen.selected <= 6 and screen.selected % 2 == 0 then
				screen.selected = screen.selected - 1
				playSound(sounds.select)
			end
		elseif self.bindings:pressed("right") then
			-- Navigate between volume controls (paired +/- buttons)
			if screen.selected <= 6 and screen.selected % 2 == 1 then
				screen.selected = screen.selected + 1
				playSound(sounds.select)
			end
		end

		if self.bindings:pressed("select") then
			local button = screen.buttons[screen.selected]
			if button and button.action then
				button.action()
			end
		end

		if self.bindings:pressed("quit") then
			self.currentScreen = "menu"
			self:saveSettings()
			playSound(sounds.select)
		end
	end
end

function mainMenuScene:adjustVolume(type, direction)
	local volKey = type == "master" and "masterVol" or (type == "music" and "musicVol" or "sfxVol")
	local currentVol = gameSettings[volKey]

	if direction > 0 then
		if currentVol < 1 then
			gameSettings[volKey] = math.min(1, math.floor(currentVol * 10 + 1) / 10)
			playSound(sounds.select)
		else
			playSound(sounds.select)
		end
	else
		if currentVol > 0 then
			gameSettings[volKey] = math.max(0, math.floor(currentVol * 10 - 1) / 10)
			playSound(sounds.select)
		else
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
	-- if sprites.ui.title then
	-- 	love.graphics.draw(sprites.ui.title, 0, 0)
	-- else
	-- Fallback background
	love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, 1)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	love.graphics.setColor(1, 1, 1, 1)
	-- end

	-- Draw menu
	if self.currentScreen == "menu" then
		self:drawMenuScreen()
	elseif self.currentScreen == "settings" then
		self:drawSettingsScreen()
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
			love.graphics.setColor(0, 1, 1, 1)
			love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - 60, y - 2, 120, 18)
		end

		-- Draw button text
		love.graphics.setColor(1, 1, 1, 1)
		if button.disabled then
			love.graphics.setColor(0.5, 0.5, 0.5, 1) -- Grey out disabled buttons
		end
		local text = button.name
		local textWidth = fonts.default:getWidth(text)
		love.graphics.print(text, fonts.default, gameSettings.gameWidth / 2 - textWidth / 2, y)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function mainMenuScene:drawSettingsScreen()
	local screen = self.screens.settings
	local yOffset = Constants.MENU.SETTINGS_Y_OFFSET
	local rowSpacing = Constants.MENU.SETTINGS_ROW_SPACING
	local barLeft = math.floor(gameSettings.gameWidth * Constants.MENU.SETTINGS_BAR_LEFT_RATIO)
	local barWidth = math.floor(gameSettings.gameWidth * Constants.MENU.SETTINGS_BAR_WIDTH_RATIO)
		+ Constants.MENU.SETTINGS_BAR_WIDTH_EXTRA

	-- Draw title
	love.graphics.setColor(43 / 255, 43 / 255, 69 / 255, 1)
	local titleWidth = fonts.default:getWidth("Settings")
	love.graphics.print("Settings", fonts.default, gameSettings.gameWidth / 2 - titleWidth / 2, 8)
	love.graphics.setColor(1, 1, 1, 1)

	-- Draw volume bars with controls
	for i = 1, 3 do
		local y = yOffset + (rowSpacing * (i - 1))
		local volKey = (i == 1 and "masterVol") or (i == 2 and "musicVol") or "sfxVol"
		local volValue = gameSettings[volKey]
		local volNumber = math.floor(volValue * 10)

		-- Draw volume bar background (dark blue)
		love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, 1)
		love.graphics.rectangle("fill", barLeft, y + 1, barWidth, 14)

		-- Draw volume bar fill (mint green)
		love.graphics.setColor(146 / 255, 232 / 255, 192 / 255, 1)
		love.graphics.rectangle("fill", barLeft, y + 1, math.floor(barWidth * volValue), 14)

		-- Draw volume labels (orange text on left)
		love.graphics.setColor(240 / 255, 181 / 255, 65 / 255, 1)
		local label = (i == 1 and "Master Volume") or (i == 2 and "Music Volume") or "Effect Volume"
		love.graphics.print(label, fonts.default, barLeft + 2, y + 8 - math.floor(fonts.default:getHeight() / 2))

		-- Draw volume controls on the right side: "+ number -"
		local controlsRightX = barLeft + barWidth - Constants.MENU.SETTINGS_CONTROLS_RIGHT_OFFSET
		local plusButtonIndex = (i - 1) * 2 + 1
		local minusButtonIndex = (i - 1) * 2 + 2
		local isPlusSelected = screen.selected == plusButtonIndex
		local isMinusSelected = screen.selected == minusButtonIndex

		-- Draw plus button
		local plusX = controlsRightX
		if isPlusSelected then
			love.graphics.setColor(0, 1, 1, 1) -- Cyan highlight
			love.graphics.rectangle(
				"fill",
				plusX - Constants.MENU.SETTINGS_BUTTON_PADDING,
				y - 1,
				Constants.MENU.SETTINGS_BUTTON_WIDTH,
				Constants.MENU.SETTINGS_BUTTON_HEIGHT
			)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(
			"+",
			fonts.default,
			plusX + 6 - fonts.default:getWidth("+") / 2,
			y + 8 - math.floor(fonts.default:getHeight() / 2)
		)

		-- Draw volume number (orange) - centered between plus and minus
		love.graphics.setColor(240 / 255, 181 / 255, 65 / 255, 1)
		local numX = controlsRightX + 16
		local numWidth = fonts.default:getWidth(volNumber)
		love.graphics.print(
			volNumber,
			fonts.default,
			numX + 6 - numWidth / 2,
			y + 8 - math.floor(fonts.default:getHeight() / 2)
		)

		-- Draw minus button
		local minusX = controlsRightX + 28
		if isMinusSelected then
			love.graphics.setColor(0, 1, 1, 1) -- Cyan highlight
			love.graphics.rectangle(
				"fill",
				minusX - Constants.MENU.SETTINGS_BUTTON_PADDING,
				y - 1,
				Constants.MENU.SETTINGS_BUTTON_WIDTH,
				Constants.MENU.SETTINGS_BUTTON_HEIGHT
			)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(
			"-",
			fonts.default,
			minusX + 6 - fonts.default:getWidth("-") / 2,
			y + 8 - math.floor(fonts.default:getHeight() / 2)
		)
	end

	-- Draw shader toggle
	local shaderYOffset = Constants.MENU.SETTINGS_Y_OFFSET
		+ (Constants.MENU.SETTINGS_ROW_SPACING * Constants.MENU.SHADER_Y_OFFSET_AFTER_VOLUME)
	local crtButtonIndex = 7
	local backButtonIndex = 8

	-- CRT Shader toggle
	local crtY = shaderYOffset
	local crtText = "CRT Shader: " .. (shaderSystem.enabled.crt and "ON" or "OFF")
	if screen.selected == crtButtonIndex then
		love.graphics.setColor(0, 1, 1, 1)
		local textWidth = fonts.default:getWidth(crtText)
		love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - textWidth / 2 - 4, crtY - 2, textWidth + 8, 16)
	end
	love.graphics.setColor(1, 1, 1, 1)
	local textWidth = fonts.default:getWidth(crtText)
	love.graphics.print(crtText, fonts.default, gameSettings.gameWidth / 2 - textWidth / 2, crtY)

	-- Back button
	local backY = gameSettings.gameHeight - Constants.MENU.BACK_BUTTON_Y_OFFSET
	if screen.selected == backButtonIndex then
		love.graphics.setColor(0, 1, 1, 1)
		local textWidth = fonts.default:getWidth("Back")
		love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - textWidth / 2 - 4, backY - 2, textWidth + 8, 16)
	end
	love.graphics.setColor(1, 1, 1, 1)
	local textWidth = fonts.default:getWidth("Back")
	love.graphics.print("Back", fonts.default, gameSettings.gameWidth / 2 - textWidth / 2, backY)
end

function mainMenuScene:keypressed(key)
	-- Input is handled in update
end

return mainMenuScene
