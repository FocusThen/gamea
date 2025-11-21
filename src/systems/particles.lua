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

-- Create death explosion particles (particles explode outward from player)
function particles:createDeathExplosion(x, y, width, height, duration, onComplete)
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
	
	-- Random directions for explosion
	local directions = {
		{ x = -1, y = -1 }, { x = 1, y = -1 },
		{ x = -1, y = 0 }, { x = 1, y = 0 },
		{ x = -1, y = 1 }, { x = 1, y = 1 }
	}
	
	-- Create particles in a 2x3 grid that explode outward
	for row = 0, 2 do
		for col = 0, 1 do
			local pieceX = x + col * pieceWidth
			local pieceY = y + row * pieceHeight
			local dir = directions[row * 2 + col + 1]
			local distance = 30 + (row * 5) + (col * 3) -- Vary explosion distance
			local destX = pieceX + dir.x * distance
			local destY = pieceY + dir.y * distance
			
			local particle = {
				x = pieceX,
				y = pieceY,
				width = pieceWidth,
				height = pieceHeight,
				startX = pieceX,
				startY = pieceY,
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
				
				-- Ease out for explosion
				local eased = 1 - (1 - self.progress) ^ 2
				
				self.x = self.startX + (self.destX - self.startX) * eased
				self.y = self.startY + (self.destY - self.startY) * eased
				
				-- Fade out as particles move
				self.alpha = math.max(0, 1 - self.progress * 1.5)
				
				if self.progress >= 1 then
					self.complete = true
					particleGroup.completedCount = particleGroup.completedCount + 1
					if particleGroup.completedCount >= particleGroup.totalParticles then
						particleGroup.complete = true
					end
				end
			end
			
			particle.draw = function(self)
				love.graphics.setColor(0, 0, 0, self.alpha or 1)
				love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.width, self.height)
			end
			
			particle.alpha = 1
			table.insert(particleGroup.particles, particle)
			particleGroup.totalParticles = particleGroup.totalParticles + 1
		end
	end
	
	table.insert(self.customParticles, particleGroup)
	return particleGroup
end

-- Create spawn combination particles (particles come together from scattered positions)
function particles:createSpawnCombination(x, y, width, height, duration, onComplete)
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
	
	-- Random starting positions for combination
	local directions = {
		{ x = -1, y = -1 }, { x = 1, y = -1 },
		{ x = -1, y = 0 }, { x = 1, y = 0 },
		{ x = -1, y = 1 }, { x = 1, y = 1 }
	}
	
	-- Create particles in a 2x3 grid that come together
	for row = 0, 2 do
		for col = 0, 1 do
			local destX = x + col * pieceWidth
			local destY = y + row * pieceHeight
			local dir = directions[row * 2 + col + 1]
			local distance = 30 + (row * 5) + (col * 3) -- Vary starting distance
			local startX = destX + dir.x * distance
			local startY = destY + dir.y * distance
			
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
				
				-- Ease in for combination
				local eased = self.progress ^ 2
				
				self.x = self.startX + (self.destX - self.startX) * eased
				self.y = self.startY + (self.destY - self.startY) * eased
				
				-- Fade in as particles come together
				self.alpha = math.min(1, self.progress * 1.5)
				
				if self.progress >= 1 then
					self.complete = true
					particleGroup.completedCount = particleGroup.completedCount + 1
					if particleGroup.completedCount >= particleGroup.totalParticles then
						particleGroup.complete = true
					end
				end
			end
			
			particle.draw = function(self)
				love.graphics.setColor(0, 0, 0, self.alpha or 0)
				love.graphics.rectangle("fill", math.floor(self.x), math.floor(self.y), self.width, self.height)
			end
			
			particle.alpha = 0
			table.insert(particleGroup.particles, particle)
			particleGroup.totalParticles = particleGroup.totalParticles + 1
		end
	end
	
	table.insert(self.customParticles, particleGroup)
	return particleGroup
end

return particles
