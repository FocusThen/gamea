local particles = Object:extend()

function particles:new()
	self.effects = {}
	self.activeEffects = {}
	self.customParticles = {} -- For custom rectangular particles

	self:loadEffects()
end

function particles:update(dt)
	-- Update sprite-based effects
	for i = #self.activeEffects, 1, -1 do
		if self.activeEffects[i].anim.status == "playing" then
			self.activeEffects[i].anim:update(dt)
		else
			table.remove(self.activeEffects, i)
		end
	end
	
	-- Update custom particles (teleport particles, etc.)
	for i = #self.customParticles, 1, -1 do
		local particleGroup = self.customParticles[i]
		-- Update all particles in the group
		if particleGroup.particles then
			for _, particle in ipairs(particleGroup.particles) do
				if particle.update then
					particle:update(dt)
				end
			end
		end
		
		-- Check if group is complete
		if particleGroup.complete then
			if particleGroup.onComplete then
				particleGroup.onComplete()
			end
			table.remove(self.customParticles, i)
		end
	end
end

function particles:draw()
	-- Draw sprite-based effects
	for _, effect in ipairs(self.activeEffects) do
		effect.anim:draw(effect.sheet, math.floor(effect.x), math.floor(effect.y))
	end
	
	-- Draw custom particles
	for _, particleGroup in ipairs(self.customParticles) do
		if particleGroup.particles then
			for _, particle in ipairs(particleGroup.particles) do
				if particle.draw then
					particle:draw()
				end
			end
		end
	end
end

function particles:createEffect(effect, x, y, flip)
	table.insert(
		self.activeEffects,
		{ anim = deepcopy(self.effects[effect].anim), sheet = self.effects[effect].sheet, x = x, y = y }
	)

	if flip then
		self.activeEffects[#self.activeEffects].anim:flipH()
	end
end

function particles:loadEffects()
	self.effects["jump"] = {}
	self.effects["jump"].sheet = sprites.particles.jump
	self.effects["jump"].sheet:setFilter("nearest", "nearest")
	local ejg = anim8.newGrid(20, 6, self.effects["jump"].sheet:getWidth(), self.effects["jump"].sheet:getHeight())
	self.effects["jump"].anim = anim8.newAnimation(ejg("1-7", 1), 0.075, "pauseAtEnd")

	self.effects["dash"] = {}
	self.effects["dash"].sheet = sprites.particles.smoke
	self.effects["dash"].sheet:setFilter("nearest", "nearest")
	local edg = anim8.newGrid(16, 10, self.effects["dash"].sheet:getWidth(), self.effects["dash"].sheet:getHeight())
	self.effects["dash"].anim = anim8.newAnimation(edg("1-6", 1), 0.1, "pauseAtEnd")

	self.effects["landing"] = {}
	self.effects["landing"].sheet = sprites.particles.landing
	self.effects["landing"].sheet:setFilter("nearest", "nearest")
	local elg =
		anim8.newGrid(16, 4, self.effects["landing"].sheet:getWidth(), self.effects["landing"].sheet:getHeight())
	self.effects["landing"].anim = anim8.newAnimation(elg("1-4", 1), 0.075, "pauseAtEnd")

	self.effects["boxLanding"] = {}
	self.effects["boxLanding"].sheet = sprites.particles.boxlanding
	self.effects["boxLanding"].sheet:setFilter("nearest", "nearest")
	local eblg =
		anim8.newGrid(28, 4, self.effects["boxLanding"].sheet:getWidth(), self.effects["boxLanding"].sheet:getHeight())
	self.effects["boxLanding"].anim = anim8.newAnimation(eblg("1-4", 1), 0.075, "pauseAtEnd")

	self.effects["walk"] = {}
	self.effects["walk"].sheet = sprites.particles.walking
	self.effects["walk"].sheet:setFilter("nearest", "nearest")
	local ewg = anim8.newGrid(10, 3, self.effects["walk"].sheet:getWidth(), self.effects["walk"].sheet:getHeight())
	self.effects["walk"].anim = anim8.newAnimation(ewg("1-6", 1), 0.1, "pauseAtEnd")
end

-- Create teleport particle effect (rectangular pieces that move to destination)
function particles:createTeleportParticles(startX, startY, destX, destY, width, height, duration, onComplete)
	local particleGroup = {
		particles = {},
		complete = false,
		onComplete = onComplete,
		completedCount = 0,
		totalParticles = 0
	}
	
	-- Create rectangular pieces (split player into 6 pieces)
	local pieces = 6
	local pieceWidth = width / 2
	local pieceHeight = height / 3
	
	-- Create particles in a 2x3 grid
	for row = 0, 2 do
		for col = 0, 1 do
			local pieceX = startX + col * pieceWidth
			local pieceY = startY + row * pieceHeight
			local destPieceX = destX + col * pieceWidth
			local destPieceY = destY + row * pieceHeight
			
			local particle = {
				x = pieceX,
				y = pieceY,
				width = pieceWidth,
				height = pieceHeight,
				startX = pieceX,
				startY = pieceY,
				destX = destPieceX,
				destY = destPieceY,
				progress = 0,
				duration = duration + (row * 0.05) + (col * 0.03), -- Slight stagger
				elapsed = 0,
				complete = false
			}
			
			particle.update = function(self, dt)
				self.elapsed = self.elapsed + dt
				self.progress = math.min(self.elapsed / self.duration, 1)
				
				-- Ease out cubic for smooth movement
				local eased = 1 - (1 - self.progress) ^ 3
				
				self.x = self.startX + (self.destX - self.startX) * eased
				self.y = self.startY + (self.destY - self.startY) * eased
				
				if self.progress >= 1 then
					self.complete = true
					particleGroup.completedCount = particleGroup.completedCount + 1
					if particleGroup.completedCount >= particleGroup.totalParticles then
						particleGroup.complete = true
					end
				end
			end
			
			particle.draw = function(self)
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.width, self.height)
			end
			
			table.insert(particleGroup.particles, particle)
			particleGroup.totalParticles = particleGroup.totalParticles + 1
		end
	end
	
	table.insert(self.customParticles, particleGroup)
	return particleGroup
end

-- Unified function for particle explosion/combination effects
-- direction: "outward" for explosion (death), "inward" for combination (spawn)
function particles:createParticleExplosion(x, y, width, height, duration, onComplete, direction)
	direction = direction or "outward" -- Default to explosion
	
	local particleGroup = {
		particles = {},
		complete = false,
		onComplete = onComplete,
		completedCount = 0,
		totalParticles = 0
	}
	
	-- Create rectangular pieces (split player into 6 pieces)
	local pieceWidth = width / 2
	local pieceHeight = height / 3
	
	-- Directions for particle movement
	local directions = {
		{ x = -1, y = -1 }, { x = 1, y = -1 },
		{ x = -1, y = 0 }, { x = 1, y = 0 },
		{ x = -1, y = 1 }, { x = 1, y = 1 }
	}
	
	local isOutward = direction == "outward"
	
	-- Create particles in a 2x3 grid
	for row = 0, 2 do
		for col = 0, 1 do
			local centerX = x + col * pieceWidth
			local centerY = y + row * pieceHeight
			local dir = directions[row * 2 + col + 1]
			local distance = 30 + (row * 5) + (col * 3)
			
			local startX, startY, destX, destY
			if isOutward then
				-- Explosion: start at center, move outward
				startX = centerX
				startY = centerY
				destX = centerX + dir.x * distance
				destY = centerY + dir.y * distance
			else
				-- Combination: start scattered, move to center
				startX = centerX + dir.x * distance
				startY = centerY + dir.y * distance
				destX = centerX
				destY = centerY
			end
			
			local particle = {
				x = startX,
				y = startY,
				width = pieceWidth,
				height = pieceHeight,
				startX = startX,
				startY = startY,
				destX = destX,
				destY = destY,
				progress = 0,
				duration = duration + (row * 0.05) + (col * 0.03), -- Slight stagger
				elapsed = 0,
				complete = false
			}
			
			particle.update = function(self, dt)
				self.elapsed = self.elapsed + dt
				self.progress = math.min(self.elapsed / self.duration, 1)
				
				-- Easing: ease out for explosion, ease in for combination
				local eased = isOutward and (1 - (1 - self.progress) ^ 2) or (self.progress ^ 2)
				
				self.x = self.startX + (self.destX - self.startX) * eased
				self.y = self.startY + (self.destY - self.startY) * eased
				
				-- Alpha: fade out for explosion, fade in for combination
				if isOutward then
					self.alpha = math.max(0, 1 - self.progress * 1.5)
				else
					self.alpha = math.min(1, self.progress * 1.5)
				end
				
				if self.progress >= 1 then
					self.complete = true
					particleGroup.completedCount = particleGroup.completedCount + 1
					if particleGroup.completedCount >= particleGroup.totalParticles then
						particleGroup.complete = true
					end
				end
			end
			
			particle.draw = function(self)
				local defaultAlpha = isOutward and 1 or 0
				love.graphics.setColor(0, 0, 0, self.alpha or defaultAlpha)
				love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.width, self.height)
			end
			
			particle.alpha = isOutward and 1 or 0
			table.insert(particleGroup.particles, particle)
			particleGroup.totalParticles = particleGroup.totalParticles + 1
		end
	end
	
	table.insert(self.customParticles, particleGroup)
	return particleGroup
end

-- Create death explosion particles (particles explode outward from player)
function particles:createDeathExplosion(x, y, width, height, duration, onComplete)
	return self:createParticleExplosion(x, y, width, height, duration, onComplete, "outward")
end

-- Create spawn combination particles (particles come together from scattered positions)
function particles:createSpawnCombination(x, y, width, height, duration, onComplete)
	return self:createParticleExplosion(x, y, width, height, duration, onComplete, "inward")
end

return particles
