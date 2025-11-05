local trigger = Object:extend()

function trigger:new(x, y, props)
	self.x = x
	self.y = y
	self.width = props and props.width or 16
	self.height = props and props.height or 16
	self.type = "trigger"
	self.activated = false
	
	-- Properties from Tiled
	self.moveX = props and (props.moveX or 0) or 0
	self.moveY = props and (props.moveY or 0) or 0
	self.once = props and (props.once ~= false) or true -- Default to true
	self.targetId = props and props.targetId or nil -- ID of target object
	self.speed = props and props.speed or nil -- Movement speed in pixels per second
	self.duration = props and props.duration or nil -- Movement duration in seconds (used if speed is not set)
	
	-- Target object (will be linked by loadLevel)
	self.target = nil
	
	-- Tweening
	self.isMoving = false
	self.startX = nil
	self.startY = nil
	self.endX = nil
	self.endY = nil
	
	-- Add to world but as non-collidable (cross response)
	World:add(self, self.x, self.y, self.width, self.height)
end

function trigger:activate()
	if self.once and self.activated then
		return
	end
	
	self.activated = true
	
	-- Move target object smoothly if it exists
	if self.target then
		self.startX = self.target.x or 0
		self.startY = self.target.y or 0
		self.endX = self.startX + self.moveX
		self.endY = self.startY + self.moveY
		
		-- Calculate duration based on speed or use provided duration
		local distance = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
		local movementDuration
		if self.speed and self.speed > 0 then
			movementDuration = distance / self.speed
		else
			movementDuration = self.duration or 0.5
		end
		
		self.isMoving = true
		
		-- Create tween for smooth movement (both x and y together)
		local tweenVars = { x = self.endX }
		if self.target.y then
			tweenVars.y = self.endY
		end
		
		flux.to(self.target, movementDuration, tweenVars):oncomplete(function()
			self.isMoving = false
			-- Final physics world update
			if World:hasItem(self.target) then
				World:update(self.target, self.target.x, self.target.y or self.endY)
			end
		end)
	end
end

function trigger:interact(player)
	if not self.once or not self.activated then
		self:activate()
	end
end

function trigger:update(dt)
	-- Update physics world during smooth movement
	if self.isMoving and self.target and World:hasItem(self.target) then
		World:update(self.target, self.target.x, self.target.y)
	end
end

function trigger:draw()
	-- Triggers are invisible by default
	-- Only draw when DEBUG is enabled
	if DEBUG then
		love.graphics.setColor(1, 1, 0, 0.3)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return trigger

