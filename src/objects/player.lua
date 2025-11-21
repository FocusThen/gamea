local Constants = require("src.core.constants")
local player = Object:extend()

function player:new(x, y, props)
	self.x = x
	self.y = y
	self.xVel = 0
	self.yVel = 0
	self.width = Constants.PLAYER.WIDTH
	self.height = Constants.PLAYER.HEIGHT
	self.type = "player"

	self.drawOffXRight = Constants.PLAYER.DRAW_OFFSET_X_RIGHT
	self.drawOffXLeft = Constants.PLAYER.DRAW_OFFSET_X_LEFT
	self.drawOffY = Constants.PLAYER.DRAW_OFFSET_Y

	self.facing = true
	self.speed = Constants.PHYSICS.PLAYER_SPEED
	self.jump = Constants.PHYSICS.PLAYER_JUMP
	self.dash = Constants.PHYSICS.PLAYER_DASH
	self.jumpWhenAble = 0
	self.coyote = 0

	self.dead = false
	self.jumpEffectQueued = false
	self.airJump = false
	self.airDash = true
	self.gravity = Constants.PHYSICS.GRAVITY
	self.friction = Constants.PHYSICS.FRICTION

	self.abilities = {
		doubleJump = props and props.doubleJump or false,
		dash = props and props.dash or false,
	}

	self.filter = function(item, other)
		if other.type == "pickup" or other.type == "spike" or other.type == "door" or other.type == "trigger" or other.type == "saw" or other.type == "teleporter" then
			return "cross"
		elseif other.type == "oneWay" then
			return "oneWay"
		elseif other.type == "spring" then
			return "slide"
		else
			return "slide"
		end
	end

	self.lastFoot = 2
	self.footTimer = 0
	self.lastBounce = nil
	self.visible = false -- Start invisible for spawn animation
	self.spawning = true -- Flag to prevent movement during spawn

	World:add(self, self.x, self.y, self.width, self.height)
	self.input = self:controls()
	
	-- Create spawn combination particles
	particleEffects:createSpawnCombination(
		self.x, self.y,
		self.width, self.height,
		0.4, -- duration
		function()
			-- When particles combine, make player visible and allow movement
			self.visible = true
			self.spawning = false
		end
	)
end

function player:update(dt)
	-- Don't update if teleporting or spawning (particles are animating)
	if self.teleporting or self.spawning then
		return
	end
	
	if not self.dead then
		self.input:update()

		-- Horizontal movement
		if self.input:down("right") and not self.input:down("left") then
			self.x = self.x + self.speed * dt
			self.facing = true
		elseif self.input:down("left") and not self.input:down("right") then
			self.x = self.x - self.speed * dt
			self.facing = false
		else
			self.lastFoot = 2
			self.footTimer = 0
		end

		-- Footsteps
		if self:checkGrounded() then
			local moving = (self.input:down("right") and not self.input:down("left")) or
				(self.input:down("left") and not self.input:down("right"))
			if moving and self.footTimer <= 0 then
				if not sounds.foot1.sound:isPlaying() and not sounds.foot2.sound:isPlaying() then
					if self.lastFoot == 1 then
						playSound(sounds.foot2)
						self.lastFoot = 2
					else
						playSound(sounds.foot1)
						self.lastFoot = 1
					end
					self.footTimer = Constants.EFFECTS.FOOT_STEP_INTERVAL
				end
			elseif moving then
				self.footTimer = self.footTimer - dt
			end
		else
			self.lastFoot = 2
			self.footTimer = 0
		end
	end

	-- Update velocities
	if self.xVel > 0 or self.xVel < 0 then
		self.x = self.x + self.xVel * dt
		local mod = self.xVel > 0 and 1 or -1
		self.xVel = self.xVel - self.friction * mod * dt
		if (mod == 1 and self.xVel < 0) or (mod == -1 and self.xVel > 0) then
			self.xVel = 0
		end
	else
		self.xVel = 0
	end

	if math.abs(self.xVel) < 20 then
		self.y = self.y + self.yVel * dt
		self.yVel = self.yVel + self.gravity * dt
		if self.jumpEffectQueued then
			particleEffects:createEffect("jump", self.x + self.width / 2 - 10, self.y + self.height - 6)
			self.jumpEffectQueued = false
		end
	end

	if self:checkGrounded() and self.yVel > 0 then
		self.yVel = 0
	end

	-- Move in world and process collisions
	local actualX, actualY, cols, len = World:move(self, self.x, self.y, self.filter)
	local springHit = false
	local tileHit = false

	-- Process triggers first (before pickups, so they can move objects)
	for i, col in ipairs(cols) do
		if col.other.type == "trigger" then
			col.other:interact(self)
		end
	end

	for i, col in ipairs(cols) do
		if col.other.type == "box" then
			if col.normal.x ~= 0 then
				if math.abs(self.xVel) > 0 then
					col.other.xVel = self.xVel * 0.25
					playSound(sounds.ground2)
				else
					local x = self.facing and self.x + self.width or self.x - col.other.width
					local aX, aY, cs, l = World:move(col.other, x, col.other.y, col.other.filter)
					if self.facing then
						col.other.x = math.floor(aX + 1)
					else
						col.other.x = math.floor(aX - 1)
					end
					col.other.y = aY
				end
			end
			if col.normal.y == 1 and self.yVel < 0 then
				local aX, aY, cs, l = World:move(col.other, col.other.x, self.y - col.other.height, col.other.filter)
				col.other.x = aX
				col.other.y = aY
				local actualX2, actualY2, cols2, len2 = World:move(self, self.x, self.y, self.filter)
				actualX = actualX2
				actualY = actualY2
			elseif col.normal.y == -1 then
				tileHit = true
			end
		elseif col.other.type == "pickup" then
			col.other:onPickup()
			col.other.delete = true
			World:remove(col.other)
		elseif col.other.type == "door" or col.other.type == "spike" or col.other.type == "saw" or col.other.type == "teleporter" or col.other.type == "deadlyObject" then
			col.other:interact(self)
		elseif col.other.type == "platform" then
			tileHit = true
			if col.normal.y == 1 and self.yVel < -10 then
				for j = 1, Constants.VELOCITY.SLIP_CHECK_DISTANCE do
					local mod = j % 2 == 0 and 1 or -1
					local tryX = self.x + math.floor(j / 2 + 0.5) * mod
					World:update(self, tryX, actualY)
					local aX, aY, cs, l = World:check(self, tryX, self.y, self.filter)
					if l == 0 then
						World:update(self, tryX, self.y)
						actualX = tryX
						actualY = self.y
						break
					end
				end
				World:update(self, actualX, actualY)
			elseif col.normal.x ~= 0 and math.abs(self.xVel) > 0 then
				for j = 1, Constants.VELOCITY.SLIP_CHECK_DISTANCE do
					local mod = j % 2 == 0 and 1 or -1
					local tryY = self.y + math.floor(j / 2 + 0.5) * mod
					World:update(self, actualX, tryY)
					local aX, aY, cs, l = World:check(self, self.x, tryY, self.filter)
					if l == 0 then
						World:update(self, self.x, tryY)
						actualX = self.x
						actualY = tryY
						break
					end
				end
				World:update(self, actualX, actualY)
			end
		elseif col.other.type == "spring" then
			if self.yVel > Constants.VELOCITY.SPRING_BOUNCE_MIN then
				if self.lastBounce == nil then
					self.yVel = self.yVel - self.gravity * dt
					self.yVel = (self.yVel * -1) - 5
					self.lastBounce = self.yVel
				else
					self.yVel = self.lastBounce
				end
				springHit = true
				if math.abs(self.xVel) < Constants.VELOCITY.MIN_DASH then
					self.dashUp = true
				end
				playSound(sounds.spring)
				col.other.currentAnim = col.other.anims.anim
				col.other.currentAnim:gotoFrame(1)
				col.other.currentAnim.status = "playing"
			else
				self.yVel = 0
			end
		elseif col.other.type == "oneWay" then
			tileHit = self.y ~= actualY
		end
	end

	-- Handle landing
	if self.y ~= actualY and not springHit then
		if self.yVel > Constants.VELOCITY.LANDING_SOUND_THRESHOLD then
			playSound(sounds.ground)
			if self.input:down("left") and not self.input:down("right") then
				particleEffects:createEffect("walk", math.floor(self.x + self.width - 1), math.floor(actualY + self.height - 3), true)
			elseif self.input:down("right") and not self.input:down("left") then
				particleEffects:createEffect("walk", math.floor(self.x - 9), math.floor(actualY + self.height - 3))
			else
				particleEffects:createEffect("landing", self.x + self.width / 2 - 8, actualY + self.height - 4)
			end
		end
		self.yVel = 0
		if tileHit then
			self.lastBounce = nil
		end
	end

	if self.x ~= actualX then
		self.xVel = 0
	end

	-- Update coyote time and air jump
	if self:checkGrounded() then
		self.coyote = Constants.PHYSICS.COYOTE_TIME
		self.airJump = true
		if math.abs(self.xVel) < Constants.VELOCITY.MIN_DASH then
			self.dashUp = true
		end
		if self.jumpWhenAble > 0 then
			self:doJump()
			self.jumpWhenAble = 0
			playSound(sounds.jump)
		end
	else
		if math.abs(self.xVel) < Constants.VELOCITY.MIN_DASH then
			if self.coyote > 0 then
				self.coyote = self.coyote - dt
			end
		end
		if self.jumpWhenAble > 0 then
			self.jumpWhenAble = self.jumpWhenAble - dt
		end
	end

	-- Check if player was teleported
	if self.teleporting and self.teleportedX and self.teleportedY then
		-- Use teleported position and update physics world
		local teleX, teleY = World:move(self, self.teleportedX, self.teleportedY, self.filter)
		self.x = teleX
		self.y = teleY
		self.teleporting = false
		self.teleportedX = nil
		self.teleportedY = nil
	else
		self.x = actualX
		self.y = actualY
	end

	-- Handle jump and dash input
	if self.input:pressed("jump") then
		if self:checkGrounded() or self.coyote > 0 then
			self:doJump()
			playSound(sounds.jump)
		elseif self.airJump and self.abilities.doubleJump then
			self:doJump()
			self.airJump = false
			playSound(sounds.jump)
		else
			self.jumpWhenAble = Constants.EFFECTS.JUMP_EFFECT_DELAY
		end
	elseif self.input:pressed("dash") and self.abilities.dash then
		if self.dashUp then
			local mod = self.facing and 1 or -1
			self.xVel = self.dash * mod
			self.yVel = 0
			self.dashUp = false
			self.lastBounce = nil
			local ex = self.facing and self.x - 16 or self.x + self.width
			particleEffects:createEffect("dash", ex, self.y + self.height - 10, not self.facing)
			self.lastFoot = 2
			self.footTimer = 0
		end
	elseif self.input:pressed("left") and not self.input:down("right") and self:checkGrounded() then
		particleEffects:createEffect("walk", math.floor(self.x + self.width - 1), math.floor(self.y + self.height - 3), true)
	elseif self.input:pressed("right") and not self.input:down("left") and self:checkGrounded() then
		particleEffects:createEffect("walk", math.floor(self.x - 9), math.floor(self.y + self.height - 3))
	end
end

function player:draw()
	-- Don't draw if not visible (during teleport)
	if not self.visible then
		return
	end
	
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.width, self.height)
end

function player:checkGrounded()
	local actualX, actualY, cols, len = World:check(self, self.x, self.y + 1, self.filter)
	return actualY == math.floor(self.y)
end

function player:kill()
	if not self.dead then
		self.dead = true
		playSound(sounds.dead)
		
		-- Create death explosion particles
		self.visible = false
		particleEffects:createDeathExplosion(
			self.x, self.y,
			self.width, self.height,
			0.5, -- duration
			function()
				-- Explosion complete, player stays dead
			end
		)
		-- Camera shake is handled in game state
	end
end

function player:doJump()
	if math.abs(self.xVel) < 20 then
		particleEffects:createEffect("jump", self.x + self.width / 2 - 10, self.y + self.height - 6)
	else
		self.jumpEffectQueued = true
	end
	self.yVel = self.jump
	self.coyote = 0
end

function player:controls()
	return baton.new({
		controls = {
			left = { "key:left", "key:a", "axis:leftx-" },
			right = { "key:right", "key:d", "axis:leftx+" },
			jump = { "key:up", "key:w", "button:a", "axis:lefty-" },
			dash = { "key:space" },
			down = { "key:down", "key:s", "axis:lefty+" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
end

return player
