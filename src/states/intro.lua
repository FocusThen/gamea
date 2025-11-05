local introScene = Object:extend()

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
	-- Draw background (dark blue)
	love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, 1)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	
	-- Draw "Game 1" text
	local text = "Game 1"
	local fontSize = fonts.default:getHeight()
	local textWidth = fonts.default:getWidth(text)
	local centerX = gameSettings.gameWidth / 2 - textWidth / 2
	local centerY = gameSettings.gameHeight / 2 - fontSize / 2
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(text, fonts.default, centerX, centerY)
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

