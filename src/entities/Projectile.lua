local BaseEntity = require("src.entities.BaseEntity")
local Projectile = BaseEntity:extend()

function Projectile:new(x, y, vx, vy, owner, damage)
	Projectile.super.new(self, x, y, 8, 8)
	self.type = "projectile"

	self.vx = vx or 0
	self.vy = vy or 0
	self.owner = owner
	self.damage = damage or 10
	self.lifetime = 3 -- Destroy after 3 seconds
	self.age = 0

	-- Projectiles are solid but don't use gravity by default
	self.gravity = false
end

function Projectile:update(dt)
	self.age = self.age + dt

	-- Destroy if too old
	if self.age > self.lifetime then
		EM:removeEntity(self)
		return
	end

	Projectile.super.update(self, dt)
end

function Projectile:filter(item, other)
	-- Don't collide with owner
	if other == self.owner then
		return nil
	end

	-- Hit solid objects and enemies
	if other.type == "ground" or other.type == "wall" or other.type == "enemy" or other.type == "player" then
		return "cross"
	end

	return nil
end

function Projectile:handleCollision(other, collision)
	-- Deal damage if hitting damageable entity
	if other.takeDamage and other ~= self.owner then
		other:takeDamage(self.damage)
	end

	-- Destroy projectile on hit
	EM:removeEntity(self)
end

function Projectile:draw()
	love.graphics.setColor(1, 0.5, 0) -- Orange
	Projectile.super.draw(self)
	love.graphics.setColor(1, 1, 1)
end

return Projectile
