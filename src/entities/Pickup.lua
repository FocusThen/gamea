local BaseEntity = require("src.entities.BaseEntity")
local Pickup = BaseEntity:extend()

function Pickup:new(x, y, pickupType, value)
	Pickup.super.new(self, x, y, 16, 16)
	self.type = "pickup"
	self.pickupType = pickupType or "coin"
	self.value = value or 10

	-- Pickups are not solid
	self.solid = false
	self.gravity = false

	-- Floating animation
	self.floatTime = 0
	self.floatSpeed = 2
	self.floatHeight = 5
	self.startY = y

	-- Spin animation
	self.spinSpeed = 3
	self.spinAngle = 0
end

function Pickup:update(dt)
	-- Floating motion
	self.floatTime = self.floatTime + dt * self.floatSpeed
	self.y = self.startY + math.sin(self.floatTime) * self.floatHeight

	-- Spinning
	self.spinAngle = self.spinAngle + dt * self.spinSpeed

	-- Check for player collision manually (since we're not solid)
	local players = EM:getEntitiesByType("player")
	for _, player in ipairs(players) do
		if self:isCollidingWith(player) then
			self:collect(player)
			break
		end
	end

	Pickup.super.update(self, dt)
end

function Pickup:isCollidingWith(other)
	return self.x < other.x + other.w
		and other.x < self.x + self.w
		and self.y < other.y + other.h
		and other.y < self.y + self.h
end

function Pickup:collect(player)
	-- Handle different pickup types
	if self.pickupType == "coin" then
		-- Add score
    PM:emit("coinPickup", self.x + self.w / 2, self.y + self.h / 2)
	elseif self.pickupType == "health" then
		player.health = math.min(player.maxHealth, player.health + self.value)
	elseif self.pickupType == "powerup" then
		-- Give player power
	end

	EM:removeEntity(self)
end

function Pickup:draw()
	love.graphics.push()
	love.graphics.translate(self.x + self.w / 2, self.y + self.h / 2)
	love.graphics.rotate(self.spinAngle)

	if self.pickupType == "coin" then
		love.graphics.setColor(1, 1, 0) -- Yellow
	elseif self.pickupType == "health" then
		love.graphics.setColor(1, 0, 0) -- Red
	else
		love.graphics.setColor(0, 1, 1) -- Cyan
	end

	love.graphics.rectangle("fill", -self.w / 2, -self.h / 2, self.w, self.h)
	love.graphics.setColor(1, 1, 1)
	love.graphics.pop()
end

return Pickup
