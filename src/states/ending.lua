local endingScene = Object:extend()

local Constants = require("src.constants")

function endingScene:new()
	self.bindings = baton.new({
		controls = {
			select = { "key:space", "key:return", "key:z", "button:a" },
			quit = { "key:escape", "button:b" },
		},
		joystick = love.joystick.getJoysticks()[1],
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
	love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, 1)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	
	-- Draw "Thank you for playing!" text
	local text = "Thank you for playing!"
	local fontSize = fonts.default:getHeight()
	local textWidth = fonts.default:getWidth(text)
	local centerX = gameSettings.gameWidth / 2 - textWidth / 2
	local centerY = gameSettings.gameHeight / 2 - fontSize / 2 - 20
	
	love.graphics.setColor(146 / 255, 232 / 255, 192 / 255, self.alpha)
	love.graphics.print(text, fonts.default, centerX, centerY)
	
	-- Draw "Press any key to return to main menu"
	local subText = "Press any key to return to main menu"
	local subTextWidth = fonts.default:getWidth(subText)
	local subCenterX = gameSettings.gameWidth / 2 - subTextWidth / 2
	local subCenterY = centerY + fontSize + 16
	
	love.graphics.setColor(240 / 255, 181 / 255, 65 / 255, self.alpha)
	love.graphics.print(subText, fonts.default, subCenterX, subCenterY)
	
	love.graphics.setColor(1, 1, 1, 1)
end

function endingScene:keypressed(key)
	-- Input is handled in update
end

return endingScene

