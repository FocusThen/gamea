local BaseEntity = require("src.entities.BaseEntity")
local Ground = BaseEntity:extend()

function Ground:new(x, y, w, h, groundType)
	Ground.super.new(self, x, y, w, h)
	self.type = groundType or "ground"
	self.gravity = false -- Static objects don't need gravity
	self.vx = 0
	self.vy = 0
end

function Ground:update(dt)
	-- Ground doesn't need to update physics
	-- Override to prevent unnecessary calculations
end

function Ground:draw()
	if self.type == "ground" then
		love.graphics.setColor(0.4, 0.7, 0.4) -- Green
	elseif self.type == "platform" then
		love.graphics.setColor(0.6, 0.4, 0.2) -- Brown
	elseif self.type == "wall" then
		love.graphics.setColor(0.5, 0.5, 0.5) -- Gray
	end

	Ground.super.draw(self)
	love.graphics.setColor(1, 1, 1)
end

return Ground
