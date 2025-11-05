local camera = Object:extend()

local Constants = require("src.constants")

function camera:new()
	self.x = 0
	self.y = 0
	self.targetX = 0
	self.targetY = 0

	-- Shake state
	self.shakeIntensity = 0
	self.shakeDuration = 0
	self.shakeTimer = 0
	self.shakeX = 0
	self.shakeY = 0
end

function camera:setTarget(x, y)
	self.targetX = x
	self.targetY = y
end

function camera:shake(intensity, duration)
	self.shakeIntensity = intensity or Constants.CAMERA.SHAKE_INTENSITY
	self.shakeDuration = duration or Constants.CAMERA.SHAKE_DURATION
	self.shakeTimer = self.shakeDuration
end

function camera:update(dt)
	-- Update shake
	if self.shakeTimer > 0 then
		self.shakeTimer = self.shakeTimer - dt
		local shakeAmount = (self.shakeTimer / self.shakeDuration) * self.shakeIntensity
		self.shakeX = (math.random() - 0.5) * shakeAmount * 2
		self.shakeY = (math.random() - 0.5) * shakeAmount * 2

		if self.shakeTimer <= 0 then
			self.shakeTimer = 0
			self.shakeIntensity = 0
			self.shakeX = 0
			self.shakeY = 0
		end
	else
		self.shakeX = 0
		self.shakeY = 0
	end

	-- Smoothly follow target (can be enhanced with easing)
	self.x = self.targetX
	self.y = self.targetY
end

function camera:getOffset()
	return self.x + self.shakeX, self.y + self.shakeY
end

function camera:apply()
	local offsetX, offsetY = self:getOffset()
	love.graphics.translate(-offsetX, -offsetY)
end

function camera:unapply()
	love.graphics.origin()
end

return camera

