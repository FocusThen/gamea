local cam = Class:extend()

function cam:new()
	self.cam = Camera()
	self.smoother = Camera.smooth.damped(8)
	self.cameraScale = 1
	self.cameraBounds = {
		minX = 0,
		minY = 0,
		maxX = 0,
		maxY = 0,
	}
end

function cam:setupCameraForMap()
	local map = LM:getCurrentMap()
	if not map then
		return
	end

	-- Get map dimensions in pixels
	local mapWidth = map.width * map.tilewidth
	local mapHeight = map.height * map.tileheight

	-- Get window dimensions
	local windowWidth = love.graphics.getWidth()
	local windowHeight = love.graphics.getHeight()

	-- Calculate scale to fit map in window
	local scaleX = windowWidth / mapWidth
	local scaleY = windowHeight / mapHeight

	-- Use the smaller scale to fit entire map, or 1 if map is smaller than window
	self.cameraScale = math.min(scaleX, scaleY, 1)

	-- If map is smaller than window, center it
	if mapWidth < windowWidth and mapHeight < windowHeight then
		-- Map fits entirely in window - no camera movement needed
		self.cameraBounds.minX = mapWidth / 2
		self.cameraBounds.maxX = mapWidth / 2
		self.cameraBounds.minY = mapHeight / 2
		self.cameraBounds.maxY = mapHeight / 2
	else
		-- Map is larger - set bounds so camera doesn't show outside map
		local scaledWindowWidth = windowWidth / self.cameraScale
		local scaledWindowHeight = windowHeight / self.cameraScale

		self.cameraBounds.minX = scaledWindowWidth / 2
		self.cameraBounds.maxX = mapWidth - scaledWindowWidth / 2
		self.cameraBounds.minY = scaledWindowHeight / 2
		self.cameraBounds.maxY = mapHeight - scaledWindowHeight / 2
	end

	-- Apply scale to camera
	self.cam:zoom(self.cameraScale)
end

function cam:update(dt)
	local targetX = _G.player.x + _G.player.w / 2
	local targetY = _G.player.y + _G.player.h / 2

	-- Clamp camera position to map bounds
	targetX = math.max(self.cameraBounds.minX, math.min(self.cameraBounds.maxX, targetX))
	targetY = math.max(self.cameraBounds.minY, math.min(self.cameraBounds.maxY, targetY))

	-- Smooth camera following
	local currentX, currentY = self.cam:position()
	local lerpSpeed = 5
	local newX = currentX + (targetX - currentX) * lerpSpeed * dt
	local newY = currentY + (targetY - currentY) * lerpSpeed * dt

	-- Clamp final position
	newX = math.max(self.cameraBounds.minX, math.min(self.cameraBounds.maxX, newX))
	newY = math.max(self.cameraBounds.minY, math.min(self.cameraBounds.maxY, newY))

	self.cam:lookAt(newX, newY)
end

return cam
