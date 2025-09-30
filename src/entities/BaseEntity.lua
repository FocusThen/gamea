local BaseEntity = Class:extend()

function BaseEntity:new(x, y, w, h)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 32
	self.h = h or 32
	self.vx = 0
	self.vy = 0
	self.zIndex = 0

	-- Entity properties
	self.type = "entity"
	self.active = true
	self.visible = true
	self.destroyed = false
	self.canKill = false

	-- Physics properties
	self.solid = true
	self.gravity = true
	self.onGround = false

	-- Animation properties
	self.sprite = nil
	self.animation = nil
	self.flipX = false
	self.flipY = false

	-- Add to physics world if solid
	if self.solid then
		World:add(self, self.x, self.y, self.w, self.h)
	end
end

function BaseEntity:update(dt)
	if not self.active then
		return
	end

	-- Apply gravity if enabled
	if self.gravity then
		self.vy = self.vy + (GameConfig.physics.gravity * dt)
	end

	-- Update animation
	if self.animation then
		self.animation:update(dt)
	end

	-- Update physics if solid
	if self.solid then
		self:updatePhysics(dt)
	else
		-- Simple position update for non-solid entities
		self.x = self.x + self.vx * dt
		self.y = self.y + self.vy * dt
	end
end

function BaseEntity:updatePhysics(dt)
	-- Calculate goal position
	local goalX = self.x + self.vx * dt
	local goalY = self.y + self.vy * dt

	local filterFunc = function(item, other)
		if self.filter then
			return self:filter(item, other)
		else
			return self:defaultFilter(item, other)
		end
	end

	-- Move with collision detection
	local actualX, actualY, cols, len = World:move(self, goalX, goalY, filterFunc)

	self.x = actualX
	self.y = actualY
	self.onGround = false

	-- Handle collisions
	for i = 1, len do
		local col = cols[i]
		self:handleCollision(col.other, col)

		-- Ground detection
		if col.normal.y == -1 then
			self.vy = 0
			self.onGround = true
		elseif col.normal.y == 1 then
			self.vy = 0
		end

		-- Wall collision
		if col.normal.x ~= 0 then
			self.vx = 0
		end
	end
end

function BaseEntity:defaultFilter(_, _)
	return "slide"
end

function BaseEntity:handleCollision(_, _)
	-- Override in child classes for specific collision handling
end

function BaseEntity:draw()
	if not self.visible then
		return
	end

	if self.sprite then
		local scaleX = self.flipX and -1 or 1
		local scaleY = self.flipY and -1 or 1
		local offsetX = self.flipX and self.w or 0
		local offsetY = self.flipY and self.h or 0

		if self.animation then
			self.animation:draw(self.sprite, self.x + offsetX, self.y + offsetY, 0, scaleX, scaleY)
		else
			love.graphics.draw(self.sprite, self.x + offsetX, self.y + offsetY, 0, scaleX, scaleY)
		end
	else
		-- Default rectangle draw
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	end
end

function BaseEntity:destroy()
	if self.solid and World and World:hasItem(self) then
		World:remove(self)
	end
	self.destroyed = true
end

function BaseEntity:setPosition(x, y)
	self.x = x
	self.y = y
	if self.solid and World:hasItem(self) then
		World:update(self, x, y)
	end
end

function BaseEntity:getCenter()
	return self.x + self.w / 2, self.y + self.h / 2
end

function BaseEntity:distanceTo(other)
	local x1, y1 = self:getCenter()
	local x2, y2 = other:getCenter()
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

--AABB collision check
function BaseEntity:isCollidingWith(other)
	return self.x < other.x + other.w
		and other.x < self.x + self.w
		and self.y < other.y + other.h
		and other.y < self.y + self.h
end

return BaseEntity
