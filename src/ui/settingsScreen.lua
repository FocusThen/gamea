local SettingsScreen = Object:extend()

local Constants = require("src.core.constants")
local Colors = require("src.core.colors")

function SettingsScreen:new()
	self.selected = 1
	self.buttons = self:buildButtons()
	self.onBack = nil
end

function SettingsScreen:buildButtons()
	return {
		{ name = "Master Vol +", action = function() self:adjustVolume("master", 1) end },
		{ name = "Master Vol -", action = function() self:adjustVolume("master", -1) end },
		{ name = "Music Vol +", action = function() self:adjustVolume("music", 1) end },
		{ name = "Music Vol -", action = function() self:adjustVolume("music", -1) end },
		{ name = "SFX Vol +", action = function() self:adjustVolume("sfx", 1) end },
		{ name = "SFX Vol -", action = function() self:adjustVolume("sfx", -1) end },
		{ name = "CRT Shader", action = function() 
			shaderSystem:toggle("crt")
			playSound(sounds.select)
		end },
		{ name = "Back", action = function() 
			if self.onBack then 
				self.onBack() 
			end
		end },
	}
end

function SettingsScreen:adjustVolume(type, direction)
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

function SettingsScreen:updateNavigation(bindings)
	local maxSelection = #self.buttons
	
	if bindings:pressed("up") then
		self.selected = self.selected - 1
		if self.selected < 1 then
			self.selected = maxSelection
		end
		playSound(sounds.select)
	elseif bindings:pressed("down") then
		self.selected = self.selected + 1
		if self.selected > maxSelection then
			self.selected = 1
		end
		playSound(sounds.select)
	elseif bindings:pressed("left") then
		-- Navigate between volume controls (paired +/- buttons)
		if self.selected <= 6 and self.selected % 2 == 0 then
			self.selected = self.selected - 1
			playSound(sounds.select)
		end
	elseif bindings:pressed("right") then
		-- Navigate between volume controls (paired +/- buttons)
		if self.selected <= 6 and self.selected % 2 == 1 then
			self.selected = self.selected + 1
			playSound(sounds.select)
		end
	end
	
	if bindings:pressed("select") then
		local button = self.buttons[self.selected]
		if button and button.action then
			button.action()
		end
	end
end

function SettingsScreen:draw()
	local yOffset = Constants.MENU.SETTINGS_Y_OFFSET
	local rowSpacing = Constants.MENU.SETTINGS_ROW_SPACING
	local barLeft = math.floor(gameSettings.gameWidth * Constants.MENU.SETTINGS_BAR_LEFT_RATIO)
	local barWidth = math.floor(gameSettings.gameWidth * Constants.MENU.SETTINGS_BAR_WIDTH_RATIO) + Constants.MENU.SETTINGS_BAR_WIDTH_EXTRA

	-- Draw title
	love.graphics.setColor(Colors.TEXT_DARK)
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
		love.graphics.setColor(Colors.BACKGROUND)
		love.graphics.rectangle("fill", barLeft, y + 1, barWidth, 14)

		-- Draw volume bar fill (mint green)
		love.graphics.setColor(Colors.TEXT_PRIMARY)
		love.graphics.rectangle("fill", barLeft, y + 1, math.floor(barWidth * volValue), 14)

		-- Draw volume labels (orange text on left)
		love.graphics.setColor(Colors.TEXT_SECONDARY)
		local label = (i == 1 and "Master Volume") or (i == 2 and "Music Volume") or "Effect Volume"
		love.graphics.print(label, fonts.default, barLeft + 2, y + 8 - math.floor(fonts.default:getHeight() / 2))

		-- Draw volume controls on the right side: "+ number -"
		local controlsRightX = barLeft + barWidth - Constants.MENU.SETTINGS_CONTROLS_RIGHT_OFFSET
		local plusButtonIndex = (i - 1) * 2 + 1
		local minusButtonIndex = (i - 1) * 2 + 2
		local isPlusSelected = self.selected == plusButtonIndex
		local isMinusSelected = self.selected == minusButtonIndex

		-- Draw plus button
		local plusX = controlsRightX
		if isPlusSelected then
			love.graphics.setColor(Colors.SELECTION) -- Cyan highlight
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
		love.graphics.setColor(Colors.TEXT_SECONDARY)
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
			love.graphics.setColor(Colors.SELECTION) -- Cyan highlight
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
	if self.selected == crtButtonIndex then
		love.graphics.setColor(Colors.SELECTION)
		local textWidth = fonts.default:getWidth(crtText)
		love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - textWidth / 2 - 4, crtY - 2, textWidth + 8, 16)
	end
	love.graphics.setColor(1, 1, 1, 1)
	local textWidth = fonts.default:getWidth(crtText)
	love.graphics.print(crtText, fonts.default, gameSettings.gameWidth / 2 - textWidth / 2, crtY)

	-- Back button
	local backY = gameSettings.gameHeight - Constants.MENU.BACK_BUTTON_Y_OFFSET
	if self.selected == backButtonIndex then
		love.graphics.setColor(Colors.SELECTION)
		local textWidth = fonts.default:getWidth("Back")
		love.graphics.rectangle("fill", gameSettings.gameWidth / 2 - textWidth / 2 - 4, backY - 2, textWidth + 8, 16)
	end
	love.graphics.setColor(1, 1, 1, 1)
	local textWidth = fonts.default:getWidth("Back")
	love.graphics.print("Back", fonts.default, gameSettings.gameWidth / 2 - textWidth / 2, backY)
end

return SettingsScreen

