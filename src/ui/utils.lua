local uiUtils = {}

local Colors = require("src.core.colors")

-- Draw centered text with optional color
function uiUtils.drawCenteredText(text, font, y, color)
	color = color or Colors.WHITE
	local textWidth = font:getWidth(text)
	local centerX = gameSettings.gameWidth / 2 - textWidth / 2
	love.graphics.setColor(color)
	love.graphics.print(text, font, centerX, y)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Draw background with optional color
function uiUtils.drawBackground(color)
	color = color or Colors.BACKGROUND
	love.graphics.setColor(color)
	love.graphics.rectangle("fill", 0, 0, gameSettings.gameWidth, gameSettings.gameHeight)
	love.graphics.setColor(1, 1, 1, 1)
end

return uiUtils

