local pauseScene = Object:extend()

function pauseScene:new()
	self.bindings = baton.new({
		controls = {
			up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
			down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
			left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
			right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
			select = { "key:space", "key:return", "key:z", "button:a" },
			back = { "key:escape", "button:b" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
	
	-- Menu screens
	self.screens = {
		menu = {
			buttons = {
				{ name = "Resume", action = function() self:resume() end },
				{ name = "Settings", action = function() self.currentScreen = "settings"; playSound(sounds.select) end },
				{ name = "Level Select", action = function() self:goToLevelSelect() end },
			},
			selected = 1,
		},
		settings = {
			buttons = {
				{ name = "Master Vol +", action = function() self:adjustVolume("master", 1) end },
				{ name = "Master Vol -", action = function() self:adjustVolume("master", -1) end },
				{ name = "Music Vol +", action = function() self:adjustVolume("music", 1) end },
				{ name = "Music Vol -", action = function() self:adjustVolume("music", -1) end },
				{ name = "SFX Vol +", action = function() self:adjustVolume("sfx", 1) end },
				{ name = "SFX Vol -", action = function() self:adjustVolume("sfx", -1) end },
				{ name = "Back", action = function() self.currentScreen = "menu"; self:saveGame(); playSound(sounds.select) end },
			},
			selected = 1,
		},
	}
	
	self.currentScreen = "menu"
	self.gameStateRef = nil -- Will hold reference to game state for drawing
	self.ignoreInput = true -- Ignore input on first frame to prevent flashing
end

function pauseScene:enter(enterparams)
	-- Store reference to game state so we can draw it behind the pause menu
	self.gameStateRef = enterparams.gameState
	self.currentScreen = "menu"
	self.screens.menu.selected = 1
	self.screens.settings.selected = 1
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
		-- Settings screen: 6 volume controls (arranged in pairs) + 1 back button
		if self.bindings:pressed("up") then
			if currentScreen.selected <= 2 then
				currentScreen.selected = 7 -- Jump to back button
			elseif currentScreen.selected == 7 then
				currentScreen.selected = 5 -- Jump to last row of volume controls
			else
				currentScreen.selected = currentScreen.selected - 2
			end
			playSound(sounds.select)
		elseif self.bindings:pressed("down") then
			if currentScreen.selected == 7 then
				currentScreen.selected = 1 -- Jump to first row
			elseif currentScreen.selected >= 5 then
				currentScreen.selected = 7 -- Jump to back button
			else
				currentScreen.selected = currentScreen.selected + 2
			end
			playSound(sounds.select)
		elseif self.bindings:pressed("left") then
			if currentScreen.selected == 7 then
				-- Back button: no left/right
			elseif currentScreen.selected % 2 == 0 then
				currentScreen.selected = currentScreen.selected - 1 -- Move to plus button
				playSound(sounds.select)
			end
		elseif self.bindings:pressed("right") then
			if currentScreen.selected == 7 then
				-- Back button: no left/right
			elseif currentScreen.selected % 2 == 1 then
				currentScreen.selected = currentScreen.selected + 1 -- Move to minus button
				playSound(sounds.select)
			end
		end
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
	end
	
	if self.bindings:pressed("select") then
		currentScreen.buttons[currentScreen.selected].action()
	elseif self.bindings:pressed("back") then
		if self.currentScreen == "menu" then
			self:resume()
		else
			self.currentScreen = "menu"
			playSound(sounds.select)
		end
	end
end

function pauseScene:adjustVolume(type, direction)
	local volKey = type == "master" and "masterVol" or (type == "music" and "musicVol" or "sfxVol")
	local currentVol = gameSettings[volKey]
	
	if direction > 0 then
		if currentVol < 1 then
			gameSettings[volKey] = math.min(1, math.floor(currentVol * 10 + 1) / 10)
			playSound(sounds.select)
		else
			playSound(sounds.select) -- Use select sound as error feedback
		end
	else
		if currentVol > 0 then
			gameSettings[volKey] = math.max(0, math.floor(currentVol * 10 - 1) / 10)
			playSound(sounds.select)
		else
			playSound(sounds.select) -- Use select sound as error feedback
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

function pauseScene:saveGame()
	-- TODO: Implement save game functionality
	-- For now, just update savedGame settings
	savedGame.settings = gameSettings
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
	love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, 0.4)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	love.graphics.setColor(1, 1, 1, 1)
	
	-- Draw pause menu
	if self.currentScreen == "menu" then
		self:drawMenuScreen()
	elseif self.currentScreen == "settings" then
		self:drawSettingsScreen()
	end
end

function pauseScene:drawMenuScreen()
	local screen = self.screens.menu
	local yOffset = 64
	local buttonSpacing = 24
	
	-- Draw buttons
	for i, button in ipairs(screen.buttons) do
		local y = yOffset + (buttonSpacing * (i - 1))
		
		-- Draw selection indicator
		if i == screen.selected then
			love.graphics.setColor(0, 1, 1, 1)
			love.graphics.rectangle("fill", 
				gameSettings.gameWidth / 2 - 60, 
				y - 2, 
				120, 
				18
			)
		end
		
		-- Draw button text
		love.graphics.setColor(1, 1, 1, 1)
		local text = button.name
		local textWidth = fonts.default:getWidth(text)
		love.graphics.print(text, fonts.default, 
			gameSettings.gameWidth / 2 - textWidth / 2, 
			y
		)
	end
end

function pauseScene:drawSettingsScreen()
	local screen = self.screens.settings
	local yOffset = 56
	local rowSpacing = 32
	local barLeft = math.floor(gameSettings.gameWidth / 6)
	local barWidth = math.floor(gameSettings.gameWidth / 2) + 46
	local controlsRight = math.floor(gameSettings.gameWidth * 2 / 3)
	
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
		local controlsRightX = barLeft + barWidth - 40
		local plusButtonIndex = (i - 1) * 2 + 1
		local minusButtonIndex = (i - 1) * 2 + 2
		local isPlusSelected = screen.selected == plusButtonIndex
		local isMinusSelected = screen.selected == minusButtonIndex
		
		-- Draw plus button
		local plusX = controlsRightX
		if isPlusSelected then
			love.graphics.setColor(0, 1, 1, 1) -- Cyan highlight
			love.graphics.rectangle("fill", plusX - 2, y - 1, 12, 16)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print("+", fonts.default, plusX + 6 - fonts.default:getWidth("+") / 2, y + 8 - math.floor(fonts.default:getHeight() / 2))
		
		-- Draw volume number (orange) - centered between plus and minus
		love.graphics.setColor(240 / 255, 181 / 255, 65 / 255, 1)
		local numX = controlsRightX + 16
		local numWidth = fonts.default:getWidth(volNumber)
		love.graphics.print(volNumber, fonts.default, numX + 6 - numWidth / 2, y + 8 - math.floor(fonts.default:getHeight() / 2))
		
		-- Draw minus button
		local minusX = controlsRightX + 28
		if isMinusSelected then
			love.graphics.setColor(0, 1, 1, 1) -- Cyan highlight
			love.graphics.rectangle("fill", minusX - 2, y - 1, 12, 16)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print("-", fonts.default, minusX + 6 - fonts.default:getWidth("-") / 2, y + 8 - math.floor(fonts.default:getHeight() / 2))
	end
	
	-- Draw back button at bottom center
	local backButtonIndex = 7
	local backY = gameSettings.gameHeight - 32
	if screen.selected == backButtonIndex then
		love.graphics.setColor(0, 1, 1, 1)
		local textWidth = fonts.default:getWidth("Back")
		love.graphics.rectangle("fill", 
			gameSettings.gameWidth / 2 - textWidth / 2 - 4, 
			backY - 2, 
			textWidth + 8, 
			16
		)
	end
	love.graphics.setColor(1, 1, 1, 1)
	local textWidth = fonts.default:getWidth("Back")
	love.graphics.print("Back", fonts.default, 
		gameSettings.gameWidth / 2 - textWidth / 2, 
		backY
	)
end

return pauseScene

