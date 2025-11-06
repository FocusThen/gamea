local introScene = Object:extend()

local Colors = require("src.core.colors")
local uiUtils = require("src.ui.utils")

function introScene:new()
	self.timer = 0
	self.displayDuration = 2.0 -- Show for 2 seconds
	self.hasTransitioned = false
end

function introScene:enter()
	self.timer = 0
	self.hasTransitioned = false
	-- Use sceneEffects fade in
	sceneEffects:setFadeIn()
end

function introScene:update(dt)
	self.timer = self.timer + dt
	
	-- Auto-advance after display duration
	if self.timer >= self.displayDuration and not self.hasTransitioned then
		self.hasTransitioned = true
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("main_menu")
		end)
	end
end

function introScene:draw()
	-- Draw background
	uiUtils.drawBackground()
	
	-- Draw "Game 1" text
	local centerY = gameSettings.gameHeight / 2 - fonts.default:getHeight() / 2
	uiUtils.drawCenteredText("Game 1", fonts.default, centerY)
end

function introScene:keypressed(key)
	-- Allow skipping intro
	if key == "space" or key == "return" or key == "escape" then
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("main_menu")
		end)
	end
end

return introScene

