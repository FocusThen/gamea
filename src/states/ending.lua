local endingScene = Object:extend()

local Constants = require("src.core.constants")
local inputConfig = require("src.systems.inputConfig")
local Colors = require("src.core.colors")
local uiUtils = require("src.ui.utils")

function endingScene:new()
	self.bindings = inputConfig.createSimpleBindings({
		select = { "key:space", "key:return", "key:z", "button:a" },
		quit = { "key:escape", "button:b" },
	})
	
	self.timer = 0
	self.fadeInDuration = 1.0
	self.alpha = 0
end

function endingScene:enter()
	self.timer = 0
	self.alpha = 0
end

function endingScene:update(dt)
	self.bindings:update()
	
	-- Fade in
	if self.timer < self.fadeInDuration then
		self.timer = self.timer + dt
		self.alpha = math.min(1.0, self.timer / self.fadeInDuration)
	end
	
	if self.bindings:pressed("select") or self.bindings:pressed("quit") then
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("main_menu")
		end)
	end
end

function endingScene:draw()
	-- Draw background
	uiUtils.drawBackground()
	
	-- Draw "Thank you for playing!" text
	local fontSize = fonts.default:getHeight()
	local centerY = gameSettings.gameHeight / 2 - fontSize / 2 - 20
	
	local primaryColor = {Colors.TEXT_PRIMARY[1], Colors.TEXT_PRIMARY[2], Colors.TEXT_PRIMARY[3], self.alpha}
	uiUtils.drawCenteredText("Thank you for playing!", fonts.default, centerY, primaryColor)
	
	-- Draw "Press any key to return to main menu"
	local subY = centerY + fontSize + 16
	local secondaryColor = {Colors.TEXT_SECONDARY[1], Colors.TEXT_SECONDARY[2], Colors.TEXT_SECONDARY[3], self.alpha}
	uiUtils.drawCenteredText("Press any key to return to main menu", fonts.default, subY, secondaryColor)
end

return endingScene

