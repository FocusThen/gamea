local BaseEntity = require("src.entities.BaseEntity")
local Player = BaseEntity:extend()

function Player:new(x, y)
	Player.super.new(self, x, y, 32, 32)
	self.type = "player"

	-- Player specific properties
	self.health = 1
	self.maxHealth = 1
	self.speed = 200
	self.jumpPower = 500

	-- Movement state
	self.state = "idle" -- idle, walking, jumping, falling
	self.facing = 1 -- 1 = right, -1 = left

	-- Input handling
	self.input = {
		left = false,
		right = false,
		jump = false,
		jumpPressed = false,
	}

	-- Coyote time for better jumping
	self.coyoteTime = 0
	self.coyoteTimeMax = 0.1

	-- Load sprite and animations
	self:loadAssets()

	-- Particle effects
	self.lastGroundY = y
	self.walkTimer = 0
	self.walkParticleDelay = 0.1
end

function Player:loadAssets()
	self.sprite = AM:getTexture("player")

	-- Setup animations if available
	if AM:getAnimation("playerIdle") then
		self.animations = {
			idle = AM:getAnimation("playerIdle"),
			walk = AM:getAnimation("playerWalk"),
			jump = AM:getAnimation("playerJump"),
		}
		self.animation = self.animations.idle
	end
end

function Player:update(dt)
	local wasOnGround = self.ground
	local wasMoving = math.abs(self.vx) > 10
	self:handleInput()
	self:updateState()

	-- Update coyote time
	if self.onGround then
		self.coyoteTime = self.coyoteTimeMax
	else
		self.coyoteTime = math.max(0, self.coyoteTime - dt)
	end

	if self.ground and wasMoving then
		-- Walking dust particles
		self.walkTimer = self.walkTimer + dt
		if self.walkTimer > self.walkParticleDelay then
			PM:emit("walkDust", self.x + self.w / 2, self.y + self.h, self.facing > 0 and math.pi or 0)
			self.walkTimer = 0
		end
	end

	-- Apply movement
	if self.input.left then
		self.vx = -self.speed
		self.facing = -1
		self.flipX = true
	elseif self.input.right then
		self.vx = self.speed
		self.facing = 1
		self.flipX = false
	else
		self.vx = self.vx * 0.8 -- Friction
		if math.abs(self.vx) < 10 then
			self.vx = 0
		end
	end

	-- Jumping
	if self.input.jumpPressed and (self.onGround or self.coyoteTime > 0) then
		self.vy = -self.jumpPower
		self.coyoteTime = 0
		self.input.jumpPressed = false
		PM:emit("jumpDust", self.x + self.w / 2, self.y + self.h, math.pi / 2)
	end

	Player.super.update(self, dt)
end

function Player:handleInput()
	self.input.left = love.keyboard.isDown("left", "a")
	self.input.right = love.keyboard.isDown("right", "d")
	self.input.jump = love.keyboard.isDown("space", "up", "w")

	-- Handle jump press (for coyote time)
	if self.input.jump and not self.wasJumpPressed then
		self.input.jumpPressed = true
	end
	self.wasJumpPressed = self.input.jump
end

function Player:updateState()
	if not self.onGround then
		self.state = self.vy < 0 and "jumping" or "falling"
	elseif math.abs(self.vx) > 10 then
		self.state = "walking"
	else
		self.state = "idle"
	end

	-- Update animation based on state
	if self.animations then
		local newAnim = self.animations[self.state] or self.animations.idle
		if self.animation ~= newAnim then
			self.animation = newAnim:clone()
		end
	end
end

function Player:filter(item, other)
	if other.type == "ground" or other.type == "wall" then
		return "slide"
	elseif other.type == "platform" then
		-- One-way platforms
		if self.vy > 0 then
			return "slide"
		else
			return nil
		end
	elseif other.type == "enemy" then
		return "cross"
	elseif other.type == "pickup" then
		return nil
	end
	return "slide"
end

function Player:handleCollision(other, collision)
	if other.type == "enemy" then
		self:handleEnemyCollision(other, collision)
	end
end

function Player:handleEnemyCollision(enemy, collision)
	if collision.normal.y == -1 and self.vy > 0 then
		-- Stomp enemy
		self.vy = -300
		enemy:takeDamage(1)
	else
		-- Take damage
		self:takeDamage(1)
		-- Knockback
		-- local knockbackX = collision.normal.x * 100
		-- self.vx = self.vx + knockbackX
	end
end

function Player:takeDamage(amount)
	self.health = math.max(0, self.health - amount)
	if self.health <= 0 then
		self:die()
	end
end

function Player:die()
	PM:emit("playerDeath", self.x + self.w / 2, self.y + self.h / 2)

	-- Start death transition
	ST:setCenter(self.x + self.w / 2, self.y + self.h / 2)
	ST:startCircleOut(1.5, function()
		GSM:setState("gameover")
		ST:startCircleIn(1.0)
	end)
end

function Player:draw()
	-- Flash red when taking damage
	if self.damageFlash and self.damageFlash > 0 then
		love.graphics.setColor(1, 0.5, 0.5)
	end

	Player.super.draw(self)
	love.graphics.setColor(1, 1, 1)
end

return Player
