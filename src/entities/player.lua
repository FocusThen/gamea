local Entity = require("src.entities.entity")
local Player = Entity:extend()

function Player:new(x, y)
	Player.super.new(self)
	self.x = x
	self.y = y
	self.w = 32
	self.h = 32
	self.kind = Entity_Kinds.PLAYER

	--- Entity properties
	self.speed = 100
	self.xVel = 0
	self.yVel = 0
	self.jumpTimer = nil
	self.jumpVel = CONFIG.playerJumpInitialVelocity
	self.jumpTimeToApex = CONFIG.playerJumpTimeToApex
	self.onGround = false
	self.gravityScale = 1

	--- Entity Physics
	World:add(self, self.x, self.y, self.w, self.h)
	self:initControls()
end

function Player:update(dt)
	self.controls:update()

	local horiz = self.controls:get("right") - self.controls:get("left")
	local jumpPressed = self.controls:pressed("jump")
	local jumpReleased = self.controls:released("jump")

	-- if jumpPressed and self:isTouchingOpenDoor() then
	-- Game:advanceLevel()
	if self.onGround and jumpPressed then
		self:jump()
	end

	if jumpReleased then
		local cutoff = -3
		if self.yVel < cutoff then
			self.yVel = cutoff
		end
	end

	self.xVel = (horiz * dt * self.speed)

	self:applyGravity(dt)

	if not self._remove then
		self.onGround = false
		self:moveColliding(self.xVel, self.yVel)
	end

	-- if self:allowedToMove() then
	-- update animations
	-- end

	--  self.currentAnim = self.anims[self.state .. self.direction]
	-- self.currentAnim:update(dt)
end

function Player:draw()
	lg.setColor(CONFIG.COLORS.WHITE)
	-- local ox = self.offsetX
	-- local oy = self.offsetY
	-- local drawX = (self.x - ox) * CONFIG.scale
	-- local drawY = (self.y - oy) * CONFIG.scale
	-- local r = 0
	-- local sx = CONFIG.scale
	-- local sy = CONFIG.scale
	-- self.currentAnim:draw(self.image, drawX, drawY, r, sx, sy)

	lg.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Player:jump()
	self.yVel = -self.jumpVel
	self.onGround = false
	-- Game:playSFX("jump")
end

function Player:filter(item, other)
	if other.kind == Entity_Kinds.COLLECTIBLE then
		return "cross"
	elseif other.kind == Entity_Kinds.DOOR then
		return "cross"
	elseif other.kind == Entity_Kinds.NONE then
		return nil
	else
		return "slide" -- ground
	end
end

function Player:removeFromBumpWorld()
	World:remove(self)
end

function Player:onCollision(cols, len)
	for i = 1, len do
		local col = cols[i]

		if col.other.canKill then
			self:kill()
		elseif col.other.ground then
			if col.normal.y == -1 or col.normal.y == 1 then
				self.yVel = 0
			end

			if col.normal.y == -1 then
				self.onGround = true
				-- if self.state == "jump" then
				-- 	self:addLandingDust()
				-- end
			end
		elseif col.other.kind == Entity_Kinds.COLLECTIBLE then
			self:collectItem(col.other)
		end
	end
end

function Player:initControls()
	local options = {}

	options.controls = {
		left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
		right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
		up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
		down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
		jump = {
			"key:x",
			"key:space",
			"button:a",
			"button:x",
			"button:dpup",
			"button:rightshoulder",
			"axis:lefty-",
			"axis:triggerright+",
			"key:up",
			"key:w",
		},
		cancel = { "key:escape", "button:b" },
	}
	options.joystick = love.joystick.getJoysticks()[1]
	self.controls = baton.new(options)
end

function Player:collectItem(item)
	item:collect()
end

function Player:isTouchingOpenDoor()
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	local _, len = self.world:queryRect(x, y, w, h, function(item)
		return item.isDoor and item.isOpen
	end)
	if len > 0 then
		return true
	else
		return false
	end
end

function Player:getMidpoint()
	local x, y = self.x, self.y
	local width, height = self.width, self.height
	return x + (width / 2), y + (height / 2)
end

function Player:kill()
	if self.state == "kill" then
		return
	else
		self.state = "kill"
		-- self.currentAnim = self.anims.killRight -- thats triggers after kill animation function
		-- Game:incrementDeathTotals()
		-- Game:playSFX("hit")
		-- Timer.after(0.4, function()
		-- 	Game:playSFX("death")
		-- 	Game:playSFX("death_poof")
		-- end)
	end
end

-- function Player:afterKillAnimation()
-- 	local delay = CONFIG.respawnDelay
-- 	Timer.after(delay, function()
-- 		Game:respawnPlayer(self.respawnX, self.respawnY)
-- 	end)
-- 	self:removeFromBumpWorld()
-- 	self._remove = true
-- end

return Player
