local menuBase = Object:extend()

local Constants = require("src.constants")

function menuBase:new(buttons, config)
	config = config or {}
	self.buttons = buttons or {}
	self.selected = config.initialSelection or 1
	self.yOffset = config.yOffset or Constants.MENU.MENU_Y_OFFSET
	self.buttonSpacing = config.buttonSpacing or Constants.MENU.BUTTON_SPACING
	self.buttonWidth = config.buttonWidth or 120
	self.buttonHeight = config.buttonHeight or 18
	self.centerX = config.centerX or (gameSettings.gameWidth / 2)
end

function menuBase:updateNavigation(bindings)
	if bindings:pressed("up") then
		self.selected = self.selected - 1
		if self.selected < 1 then
			self.selected = #self.buttons
		end
		playSound(sounds.select)
	elseif bindings:pressed("down") then
		self.selected = self.selected + 1
		if self.selected > #self.buttons then
			self.selected = 1
		end
		playSound(sounds.select)
	end
end

function menuBase:handleSelect(bindings)
	if bindings:pressed("select") then
		if self.buttons[self.selected] and self.buttons[self.selected].action then
			self.buttons[self.selected].action()
		end
	end
end

function menuBase:draw()
	for i, button in ipairs(self.buttons) do
		local y = self.yOffset + (self.buttonSpacing * (i - 1))
		
		-- Draw selection indicator
		if i == self.selected then
			love.graphics.setColor(0, 1, 1, 1)
			love.graphics.rectangle("fill", 
				self.centerX - self.buttonWidth / 2, 
				y - 2, 
				self.buttonWidth, 
				self.buttonHeight
			)
		end
		
		-- Draw button text
		love.graphics.setColor(1, 1, 1, 1)
		local text = button.name
		local textWidth = fonts.default:getWidth(text)
		love.graphics.print(text, fonts.default, 
			self.centerX - textWidth / 2, 
			y
		)
	end
end

function menuBase:getSelectedButton()
	return self.buttons[self.selected]
end

function menuBase:setSelected(index)
	if index >= 1 and index <= #self.buttons then
		self.selected = index
	end
end

return menuBase

