local Constants = require("src.core.constants")
local saw = Object:extend()

function saw:new(x, y, props)
	self.x = x
	self.y = y
	self.width = props and props.width or Constants.SAW.WIDTH
	self.height = props and props.height or Constants.SAW.HEIGHT
	self.type = "saw"
	
	-- Movement properties
	self.direction = props and (props.direction or "horizontal") or "horizontal"
	self.distance = props and (props.distance or Constants.SAW.DEFAULT_DISTANCE) or Constants.SAW.DEFAULT_DISTANCE
	self.speed = props and (props.speed or Constants.SAW.DEFAULT_SPEED) or Constants.SAW.DEFAULT_SPEED
	
	-- Store initial position
	self.startX = x
	self.startY = y
	
	-- Calculate end position based on direction
	if self.direction == "horizontal" then
		self.endX = self.startX + self.distance
		self.endY = self.startY
	else
		self.endX = self.startX
		self.endY = self.startY + self.distance
	end
	
	-- Movement state
	self.movingForward = true
	self.currentProgress = 0 -- 0 to 1, where 0 = start, 1 = end
	
	-- Filter for collision detection
	self.filter = function(item, other)
		if other.type == "pickup" or other.type == "spike" or other.type == "door" or other.type == "trigger" then
			return "cross"
		else
			return "slide"
		end
	end
	
	World:add(self, self.x, self.y, self.width, self.height)
end

function saw:update(dt)
	-- Calculate movement based on direction
	local totalDistance = self.distance
	local moveDistance = self.speed * dt
	
	if self.movingForward then
		self.currentProgress = self.currentProgress + (moveDistance / totalDistance)
		if self.currentProgress >= 1.0 then
			self.currentProgress = 1.0
			self.movingForward = false
		end
	else
		self.currentProgress = self.currentProgress - (moveDistance / totalDistance)
		if self.currentProgress <= 0.0 then
			self.currentProgress = 0.0
			self.movingForward = true
		end
	end
	
	-- Calculate new position using lerp
	local newX = self.startX + (self.endX - self.startX) * self.currentProgress
	local newY = self.startY + (self.endY - self.startY) * self.currentProgress
	
	-- Update physics world
	World:update(self, newX, newY)
	self.x = newX
	self.y = newY
end

function saw:interact(player)
	player:kill()
end

function saw:draw()
	-- Draw saw as a simple rectangle with red color to indicate danger
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0.5, 0, 0, 1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)
end

return saw

