local BaseEntity = require("src.entities.BaseEntity")
local Enemy = BaseEntity:extend()

function Enemy:new(x, y)
	Enemy.super.new(self, x, y, 24, 24)
	self.type = "enemy"

	self.health = 1
	self.speed = 50
	self.direction = 1 -- 1 = right, -1 = left
	self.patrolDistance = 100
	self.startX = x

	-- AI state
	self.state = "patrol" -- patrol, chase, attack
	self.sightRange = 150
	self.attackRange = 32

	self.sprite = AM:getTexture("enemy")
end

function Enemy:update(dt)
	self:updateAI(dt)

	-- Apply AI movement
	if self.state == "patrol" then
		self:patrol()
	elseif self.state == "chase" then
		self:chase()
	end

	Enemy.super.update(self, dt)
end

function Enemy:updateAI(dt)
	-- Find player
	local players = EM:getEntitiesByType("player")
	local player = players[1]

	if player then
		local distance = self:distanceTo(player)

		if distance < self.attackRange then
			self.state = "attack"
		elseif distance < self.sightRange then
			self.state = "chase"
		else
			self.state = "patrol"
		end
	else
		self.state = "patrol"
	end
end

function Enemy:patrol()
	-- Simple back and forth patrol
	if math.abs(self.x - self.startX) > self.patrolDistance then
		self.direction = -self.direction
	end

	self.vx = self.speed * self.direction
	self.flipX = self.direction < 0
end

function Enemy:chase()
	local players = EM:getEntitiesByType("player")
	local player = players[1]

	if player then
		local px, py = player:getCenter()
		local ex, ey = self:getCenter()

		if px < ex then
			self.vx = -self.speed * 1.5 -- Chase faster than patrol
			self.flipX = true
		else
			self.vx = self.speed * 1.5
			self.flipX = false
		end
	end
end

function Enemy:takeDamage(amount)
	self.health = self.health - amount
	if self.health <= 0 then
    PM:emit("enemyDeath", self.x + self.w/2, self.y + self.h/2)
		EM:removeEntity(self)
	end
end

function Enemy:handleCollision(other, collision)
	if other.type == "wall" or other.type == "ground" then
		if collision.normal.x ~= 0 then
			self.direction = -self.direction
		end
	end
end

function Enemy:draw()
	love.graphics.setColor(1, 0.2, 0.2) -- Red color for enemy
	Enemy.super.draw(self)
	love.graphics.setColor(1, 1, 1)
end

return Enemy
