local Constants = require("src.core.constants")
local coin = Object:extend()

function coin:new(x, y)
	self.x = x
	self.y = y
	self.width = Constants.COIN.WIDTH
	self.height = Constants.COIN.HEIGHT
	self.type = "pickup"
	self.pickType = "coin"
	self.delete = false

	self.drawOffX = 0
	self.drawOffY = 0

	-- self.sprite = sprites.coin
	-- self.sprite:setFilter("nearest", "nearest")
	-- local cg = anim8.newGrid(16, 16, self.sprite:getWidth(), self.sprite:getHeight())
	-- self.coinAnim =
	-- 	anim8.newAnimation(cg("1-7", 1), { ["1-2"] = 0.1, [3] = 0.075, [4] = 0.05, [5] = 0.075, ["6-7"] = 0.1 })

	World:add(self, self.x, self.y, self.width, self.height)
end

function coin:update(dt)
	-- self.coinAnim:update(dt)
end

function coin:draw()
	-- self.coinAnim:draw(self.sprite, self.x, self.y)
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)
end

function coin:onPickup()
	if resourceManager and resourceManager.playEntry then
		resourceManager:playEntry(sounds.coin)
	else
		playSound(sounds.coin)
	end
end

return coin
