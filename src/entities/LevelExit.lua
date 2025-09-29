local BaseEntity = require("src.entities.BaseEntity")
local LevelExit = BaseEntity:extend()

function LevelExit:new(x, y)
	LevelExit.super.new(self, x, y, 32, 48)
	self.type = "exit"
	self.solid = false
	self.gravity = false
	self.zIndex = 2

	-- Visual animation
	self.glowTime = 0
	self.activated = false
end

function LevelExit:update(dt)
	if self.destroyed or self.activated then
		return
	end

	self.glowTime = self.glowTime + dt

	-- Check collision with player
	local players = EM:getEntitiesByType("player")
	for _, player in ipairs(players) do
		if self:isCollidingWith(player) then
			self:activate()
			break
		end
	end
end

function LevelExit:isCollidingWith(other)
	return self.x < other.x + other.w
		and other.x < self.x + self.w
		and self.y < other.y + other.h
		and other.y < self.y + self.h
end

function LevelExit:activate()
	self.activated = true

	-- Load next level with transition
	Timer.after(0.5, function()
    print("hello ?")
		LM:loadNextLevel(true)
	end)
end

function LevelExit:draw()
	-- Glowing door effect
	local glow = (math.sin(self.glowTime * 3) + 1) / 2
	love.graphics.setColor(0, 1, 1, 0.5 + glow * 0.5)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	-- Door frame
	love.graphics.setColor(0, 0.7, 0.7)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

	love.graphics.setColor(1, 1, 1)
end

return LevelExit
