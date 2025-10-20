local player = Object:extend()

function player:new(x, y)
	self.x = x
	self.y = y
	self.xVel = 0
	self.yVel = 0
	self.width = 5
	self.height = 14
	self.type = "player"

	self.drawOffXRight = -5.5
	self.drawOffXLeft = -3.5
	self.drawOffY = -3

	-- self.sheet = sheet
	-- self.anims = anims
	-- self.currentAnim = self.anims.idle

	--true is right, false is left
	self.facing = true
	self.speed = 60
	self.jump = -250
	self.dash = 600
	self.jumpWhenAble = 0
	self.coyote = 0

	self.dead = false
	self.jumpEffectQueued = false

	self.airJump = false
	self.airDash = true

	self.gravity = 800
	self.friction = 4000

	self.filter = function(item, other)
		if other.type == "pickup" or other.type == "spike" or other.type == "blockTile" or other.type == "door" then
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

	World:add(self, self.x, self.y, self.width, self.height)

	self.input = self:controls()
end

function player:update(dt)
	if not self.dead then
		self.input:update()

		if self.input:down("right") and not self.input:down("left") then
			self.x = self.x + self.speed * dt
			self.facing = true
		-- self.currentAnim = self.anims.run
		elseif self.input:down("left") and not self.input:down("right") then
			self.x = self.x - self.speed * dt
			self.facing = false
		-- self.currentAnim = self.anims.run
		else
			-- self.currentAnim = self.anims.idle
			self.lastFoot = 2
			self.footTimer = 0
		end

		if not self:checkGrounded() then
			-- self.currentAnim = self.anims.fall
			self.lastFoot = 2
			self.footTimer = 0
		else
			if
				self.input:down("right") and not self.input:down("left")
				or self.input:down("left") and not self.input:down("right")
			then
				if self.footTimer <= 0 then
					if not sounds.foot1.sound:isPlaying() and not sounds.foot2.sound:isPlaying() then
						if self.lastFoot == 1 then
							playSound(sounds.foot2)
							self.lastFoot = 2
						else
							playSound(sounds.foot1)
							self.lastFoot = 1
						end
						self.footTimer = 0.4
					end
				else
					self.footTimer = self.footTimer - dt
				end
			end
		end
	end -- end if not self.dead

	--update x based on velocity and slow down based on friction
	if self.xVel > 0 or self.xVel < 0 then
		self.x = self.x + self.xVel * dt
		local mod = self.xVel > 0 and 1 or -1
		self.xVel = self.xVel - self.friction * mod * dt

		--if we passed 0
		if (mod == 1 and self.xVel < 0) or (mod == -1 and self.xVel > 0) then
			self.xVel = 0
		end
	else
		self.xVel = 0
	end

	--update y based on velocity and adjust based on gravity
	if math.abs(self.xVel) < 20 then
		self.y = self.y + self.yVel * dt
		self.yVel = self.yVel + self.gravity * dt
		if self.jumpEffectQueued then
			self:doJumpEffect()
			self.jumpEffectQueued = false
		end
	end
	--actually move in the world
	local actualX, actualY, cols, len = World:move(self, self.x, self.y, self.filter)
	local springHit = false
	local tileHit = false

	for i, col in ipairs(cols) do
		if col.other.type == "box" then
			--for pushing and bonking
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

			--for upwards bonking
			if col.normal.y == 1 then
				if self.yVel < 0 then
					local aX, aY, cs, l =
						World:move(col.other, col.other.x, self.y - col.other.height, col.other.filter)

					col.other.x = aX
					col.other.y = aY

					local actualX2, actualY2, cols2, len2 = World:move(self, self.x, self.y, self.filter)
					actualX = actualX2
					actualY = actualY2
				end
			elseif col.normal.y == -1 then
				tileHit = true
			end
		elseif col.other.type == "pickup" then
			col.other.onPickup()
			col.other.delete = true
			World:remove(col.other)
		elseif col.other.type == "door" or col.other.type == "spike" then
			col.other.interact()
		elseif col.other.type == "platform" then
			if col.normal.y == 1 and self.yVel < -10 then
				local slip = false
				for j = 1, 10 do
					--do the wiggle
					local mod = j % 2 == 0 and 1 or -1
					local tryX = self.x + math.floor(j / 2 + 0.5) * mod

					World:update(self, tryX, actualY)

					local aX, aY, cs, l = World:check(self, tryX, self.y, self.filter)

					if l == 0 then
						World:update(self, tryX, self.y)
						actualX = tryX
						actualY = self.y
						slip = true
						break
					end
				end

				--if we didn't slide around, reset back to original position
				if not slip then
					World:update(self, actualX, actualY)
				end
			elseif col.normal.x ~= 0 and math.abs(self.xVel) > 0 then
				local slip = false
				for j = 1, 10 do
					local mod = j % 2 == 0 and 1 or -1
					local tryY = self.y + math.floor(j / 2 + 0.5) * mod

					World:update(self, actualX, tryY)

					local aX, aY, cs, l = World:check(self, self.x, tryY, self.filter)

					if l == 0 then
						World:update(self, self.x, tryY)
						actualX = self.x
						actualY = tryY
						slip = true
						break
					end
				end

				if not slip then
					World:update(self, actualX, actualY)
				end
			end
		elseif col.other.type == "spring" then
			--if we're going fast enough to bounce
			if self.yVel > 150 then
				--see if we were just bouncing
				if self.lastBounce == nil then
					--if we weren't make our yVel an approximate reflection of our current yVel at impact, plus a bit so we can hop up to the same height again easier
					self.yVel = self.yVel - self.gravity * dt
					self.yVel = (self.yVel * -1) - 5
					self.lastBounce = self.yVel
				else
					--otherwise make it so we bounce up to that height again
					self.yVel = self.lastBounce
				end
				springHit = true

				if math.abs(self.xVel) < 50 then
					self.dashUp = true
				end

				playSound(sounds.spring)
				col.other.currentAnim = col.other.anims.anim
				col.other.currentAnim:gotoFrame(1)
				col.other.currentAnim.status = "playing"
			else
				self.yVel = 0
			end
		elseif col.other.type == "tile" then
			tileHit = true
		elseif col.other.type == "oneWay" then
			tileHit = self.y ~= actualY
		end

		if (self.y ~= actualY or self:checkGrounded()) and not springHit then
			if self.yVel > 100 then
				playSound(sounds.ground)
				if self.input:down("left") and not self.input:down("right") then
					particleEffects:createEffect(
						"walk",
						math.floor(self.x + self.width - 1),
						math.floor(actualY + self.height - 3),
						true
					)
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

		if self:checkGrounded() then
			self.coyote = 0.1
			self.airJump = true

			if math.abs(self.xVel) < 50 then
				self.dashUp = true
			end

			if self.jumpWhenAble > 0 then
				self:doJump()
				self.jumpWhenAble = 0
				playSound(sounds.jump)
			end
		else
			if math.abs(self.xVel) < 50 then
				if self.coyote > 0 then
					self.coyote = self.coyote - dt
				end
			end

			if self.jumpWhenAble > 0 then
				self.jumpWhenAble = self.jumpWhenAble - dt
			end
		end
	end

	self.x = actualX
	self.y = actualY

	-- self.currentAnim:update(dt)

	if self.input:pressed("jump") then
		if self:checkGrounded() or self.coyote > 0 then
			self:doJump()

			playSound(sounds.jump)
		elseif self.airJump then
			self:doJump()
			self.airJump = false
			playSound(sounds.jump)
		else
			self.jumpWhenAble = 0.1
		end
	elseif self.input:pressed("dash") then
		if self.dashUp then
			local mod = self.facing and 1 or -1
			self.xVel = self.dash * mod
			self.yVel = 0
			self.dashUp = false
			self.lastBounce = nil
			playSound(self.sfx.throw)

			local ex = self.facing and self.x - 16 or self.x + self.width

			particleEffects:createEffect("dash", ex, self.y + self.height - 10, not self.facing)

			self.lastFoot = 2
			self.footTimer = 0
		end
	elseif self.input:pressed("left") and not self.input:down("right") and self:checkGrounded() then
		particleEffects:createEffect(
			"walk",
			math.floor(self.x + self.width - 1),
			math.floor(self.y + self.height - 3),
			true
		)
	elseif self.input:pressed("right") and not self.input:down("left") and self:checkGrounded() then
		particleEffects:createEffect("walk", math.floor(self.x - 9), math.floor(self.y + self.height - 3))
	end
end

function player:draw()
	if self.dashUp then
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	love.graphics.rectangle("line", math.floor(self.x), math.floor(self.y), self.width, self.height)

	-- self.currentAnim:draw(self.sheet, math.floor(self.x + offX), math.floor(self.y) + self.drawOffY)
	--
	-- if not self.facing then
	-- 	self.currentAnim:flipH()
	-- end
end

function player:checkGrounded()
	local actualX, actualY, cols, len = World:check(self, self.x, self.y + 1, self.filter)
	return actualY == self.y
end

function player:kill()
	if not self.dead then
		self.dead = true
		-- self.currentAnim = self.anims.dead
		-- self.currentAnim:gotoFrame(1)
		-- self.currentAnim.status = "playing"
		playSound(sounds.dead)
	end
end

function player:doJump()
	if math.abs(self.xVel) < 20 then
		self:doJumpEffect()
	else
		self.jumpEffectQueued = true
	end
	self.yVel = self.jump
	self.coyote = 0
end

function player:doJumpEffect()
	particleEffects:createEffect("jump", self.x + self.width / 2 - 10, self.y + self.height - 6)
end

function player:controls()
	return baton.new({
		controls = {
			left = { "key:left", "key:a", "axis:leftx-" },
			right = { "key:right", "key:d", "axis:leftx+" },
			jump = { "key:up", "key:w", "button:a", "axis:lefty-" },
			dash = { "key:space" }, -- TODO: dash key
			down = { "key:down", "key:s", "axis:lefty+" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
end

return player
