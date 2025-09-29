local ScreenTransition = Class:extend()

function ScreenTransition:new()
	self.isActive = false
	self.circleRadius = 0
	self.maxRadius = 0
	self.transitionType = "none" -- "fadeIn", "fadeOut"
	self.callback = nil
	self.duration = 1.0

	-- Center point for circle (will be updated dynamically)
	self.centerX = 0
	self.centerY = 0

	-- Update initial values
	self:updateDimensions()
end

function ScreenTransition:updateDimensions()
	-- Calculate max radius needed to cover screen
	local w, h = love.graphics.getDimensions()
	self.maxRadius = math.sqrt(w * w + h * h) / 2

	-- Update center if not explicitly set
	if not self.customCenter then
		self.centerX = w / 2
		self.centerY = h / 2
	end
end

function ScreenTransition:startCircleIn(duration, callback)
	self:updateDimensions() -- Update for current screen size

	self.isActive = true
	self.transitionType = "fadeIn"
	self.callback = callback
	self.duration = duration or 1.0

	-- Start with full circle, shrink to reveal game
	self.circleRadius = self.maxRadius

	Flux.to(self, self.duration, { circleRadius = 0 }):ease("quartout"):oncomplete(function()
		self.isActive = false
		self.customCenter = false -- Reset custom center
		if self.callback then
			self.callback()
		end
	end)
end

function ScreenTransition:startCircleOut(duration, callback)
	self:updateDimensions() -- Update for current screen size

	self.isActive = true
	self.transitionType = "fadeOut"
	self.callback = callback
	self.duration = duration or 1.0

	-- Start with no circle, grow to cover screen
	self.circleRadius = 0

	Flux.to(self, self.duration, { circleRadius = self.maxRadius }):ease("quartin"):oncomplete(function()
		if self.callback then
			self.callback()
		end
		-- Keep circle active for fadeIn
	end)
end

function ScreenTransition:setCenter(x, y)
	-- Convert world coordinates to screen coordinates if camera exists
	if GSM and GSM.states.game and GSM.states.game.camera then
		local cam = GSM.states.game.camera
		self.centerX, self.centerY = cam:worldCoords(x, y)
	else
		self.centerX = x
		self.centerY = y
	end
	self.customCenter = true
end

function ScreenTransition:draw()
	if not self.isActive then
		return
	end

	-- Update dimensions in case window was resized
	local w, h = love.graphics.getDimensions()

	if self.transitionType == "fadeIn" then
		-- Draw black screen with circle hole
		love.graphics.stencil(function()
			love.graphics.circle("fill", self.centerX, self.centerY, self.circleRadius)
		end, "replace", 1)

		love.graphics.setStencilTest("equal", 0)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setStencilTest()
		love.graphics.setColor(1, 1, 1, 1)
	elseif self.transitionType == "fadeOut" then
		-- Draw black circle that grows
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.circle("fill", self.centerX, self.centerY, self.circleRadius)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return ScreenTransition
