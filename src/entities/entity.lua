local Entity = Object:extend()

Entity_Kinds = {
	NONE = "none",
	PLAYER = "player",
	DOOR = "door",
	COLLECTIBLE = "collectible",
  GROUND = "ground"
}

function Entity:new()
	self.kind = Entity_Kinds.NONE

	self._remove = false
end

function Entity:remove()
	self._remove = true
end

function Entity:moveColliding(dx, dy)
	if self._remove then
		return
	end
	if not World then
		return
	end
	if not World:hasItem(self) then
		return
	end

	local goalx, goaly = self.x + dx, self.y + dy

	local actualX, actualY, cols, len = World:move(self, goalx, goaly, function(item, other)
		return self:filter(item, other)
	end)

	if type(self.onCollision) == "function" and len > 0 then
		self:onCollision(cols, len)
	end
	self.x = actualX
	self.y = actualY
end

function Entity:removeFromWorld()
	if World:hasItem(self) then
		World:remove(self)
	end
end

function Entity:filter(item, other)
	-- to be overwritten by classes
	return "slide"
end

function Entity:applyGravity(dt)
	if self.yVel < CONFIG.terminalVelocity then
		self.yVel = self.yVel + self.gravityScale * CONFIG.gravity * dt
	elseif not self.onGround then
		self.yVel = CONFIG.terminalVelocity * self.gravityScale * dt
	end
end

return Entity
