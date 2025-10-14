local BaseEntity = require("src.entities.BaseEntity")
local Player = BaseEntity:extend()

function Player:new(x, y)
	Player.super.new(self, x, y, 32, 32)
	self.type = "player"
	self.zIndex = 10
  self.alive = true

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
	if not self.alive then
		return
	end

	self:handleInput()
	self:updateState()

	-- Update coyote time
	if self.onGround then
		self.coyoteTime = self.coyoteTimeMax
	else
		self.coyoteTime = math.max(0, self.coyoteTime - dt)
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

-- function Player:dash()
-- 	if not self.canDash then
-- 		return
-- 	end
--
-- 	self.vx = self.facing * 400
-- 	self.canDash = false
--
-- 	-- Dash particles
-- 	local direction = self.facing > 0 and math.pi or 0
-- 	PM:emit("dashTrail", self.x + self.w / 2, self.y + self.h / 2, direction + math.pi)
--
-- 	Timer.after(1.0, function()
-- 		self.canDash = true
-- 	end)
-- end

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
	end
	if not other.solid then
		return nil
	end
	return "slide"
end

function Player:handleCollision(other, collision)
	if other.canKill then
		self:handleEnemyCollision(other, collision) -- any cross = dead
	end
end

function Player:handleEnemyCollision(enemy, collision)
	self:takeDamage(1) -- basically die
end

function Player:takeDamage(amount)
	self.health = math.max(0, self.health - amount)
	if self.health <= 0 then
		self:die()
	end
end

function Player:die()
	if not self.alive then
		return
	end
	createExplosion(self.x + self.w / 2, self.y + self.h / 2)
	self.alive = false

  GSM:setState("gameover")
end

function Player:draw()
	Player.super.draw(self)
end

function createExplosion(x, y)
	-- Particle explosion
	PM:emit("explosion", x, y)

	-- Camera shake (add to GameState)
	if GSM.states.game and GSM.states.game.camera then
		local cam = GSM.states.game.camera

		-- Simple shake
		for i = 1, 10 do
			Timer.after(i * 0.05, function()
				local shakeX = (math.random() - 0.5) * 20
				local shakeY = (math.random() - 0.5) * 20
				local cx, cy = cam:position()
				cam:lookAt(cx + shakeX, cy + shakeY)
			end)
		end
	end
end

return Player
