local Constants = require("src.constants")
local box = Object:extend()

function box:new(x, y)
	self.x = x
	self.y = y
	self.width = Constants.BOX.WIDTH
	self.height = Constants.BOX.HEIGHT
	self.xVel = 0
	self.yVel = 0
	self.type = "box"
	self.delete = false
	self.gravity = Constants.BOX.GRAVITY
	self.friction = Constants.BOX.FRICTION
	self.lastBounce = nil
	self.filter = function(item, other)
		if other.type == "pickup" or other.type == "spike" or other.type == "door" then
			return "cross"
		elseif other.type == "oneWay" then
			return "oneWay"
		else
			return "slide"
		end
	end
	World:add(self, self.x, self.y, self.width, self.height)
end

function box:update(dt)
	-- Apply vertical movement
	self.y = self.y + self.yVel * dt
	self.yVel = self.yVel + self.gravity * dt

	-- Apply horizontal movement and friction
	if self.xVel ~= 0 then
		self.x = self.x + self.xVel * dt
		local mod = self.xVel > 0 and 1 or -1
		local frictionAmount = self:checkGrounded() and self.friction or Constants.BOX.FRICTION_AIR

		if math.abs(self.xVel) > Constants.VELOCITY.BOX_X_VEL_THRESHOLD then
			self.xVel = self.xVel - frictionAmount * mod * dt
		else
			self.xVel = self.xVel - Constants.BOX.FRICTION_AIR * mod * dt
		end

		-- Stop if we crossed zero
		if (mod == 1 and self.xVel < 0) or (mod == -1 and self.xVel > 0) then
			self.xVel = 0
		end
	end

	if self:checkGrounded() then
		self.y = math.floor(self.y)
		self.x = math.floor(self.x)
		self.lastBounce = nil
		if self.yVel > 0 then
			self.yVel = 0
		end
	end

	-- Actually move in the world
	local actualX, actualY, cols, len = World:move(self, self.x, self.y, self.filter)
	local springHit = false
	local tileHit = false

	for i, col in ipairs(cols) do
		if col.other.type == "spring" then
			-- If we're going fast enough to bounce
			if self.yVel > Constants.VELOCITY.BOX_SPRING_BOUNCE_MIN then
				-- See if we were just bouncing
				if self.lastBounce == nil then
					-- If we weren't make our yVel an approximate reflection of our current yVel at impact
					self.yVel = self.yVel - self.gravity * dt
					self.yVel = (self.yVel * -1)
					self.lastBounce = self.yVel
				else
					-- Otherwise make it so we bounce up to that height again
					self.yVel = self.lastBounce
				end
				springHit = true
				playSound(sounds.spring)
				col.other.currentAnim = col.other.anims.anim
				col.other.currentAnim:gotoFrame(1)
				col.other.currentAnim.status = "playing"
			else
				self.yVel = 0
			end
		elseif col.other.type == "player" then
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
			end
		end
	end

	-- Reset velocity if we hit something
	if self.y ~= actualY and not springHit then
		if self.yVel > Constants.VELOCITY.LANDING_SOUND_THRESHOLD then
			playSound(sounds.ground2)
			particleEffects:createEffect("boxLanding", self.x + self.width / 2 - 14, actualY + self.height - 4)
		end
		if self.yVel > 0 then
			self.yVel = 0
		end
	end

	if self.x ~= actualX then
		if math.abs(self.xVel) > Constants.VELOCITY.BOX_X_VEL_MIN then
			playSound(sounds.ground2)
		end
		self.xVel = 0
	end

	if springHit then
		self.xVel = 0
	end

	self.x = actualX
	self.y = actualY
end

function box:draw()
	love.graphics.setColor(0, 1, 1, 1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function box:checkGrounded()
	local actualX, actualY, cols, len = World:check(self, self.x, self.y + 1, self.filter)
	return len > 0 and actualY < self.y + 1
end

return box
