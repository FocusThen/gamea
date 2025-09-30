local BaseEntity = require("src.entities.BaseEntity")
local Pickup = BaseEntity:extend()

function Pickup:new(id, x, y, pickupType)
	Pickup.super.new(self, x, y, 16, 16)
	self.entity_id = id
	self.type = "pickup"
	self.pickupType = pickupType or "coin"
	self.zIndex = 3

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

function Pickup:collect(player) -- player
	if self.pickupType == "coin" then
		print("+1 coin")
	elseif self.pickupType == "fake_coin" then
		player:die()
	end

	EM:removeEntity(self)
end

function Pickup:draw()
	love.graphics.push()
	love.graphics.translate(self.x + self.w / 2, self.y + self.h / 2)
	love.graphics.rotate(self.spinAngle)

	love.graphics.setColor(1, 1, 0) -- Yellow

	love.graphics.rectangle("fill", -self.w / 2, -self.h / 2, self.w, self.h)
	love.graphics.setColor(1, 1, 1)
	love.graphics.pop()
end

return Pickup
