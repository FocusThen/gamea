local ParticleManager = Class:extend()

function ParticleManager:new()
	self.particles = {}
	self.particleTypes = self:createParticleTypes()
end

function ParticleManager:createParticleTypes()
	return {
		coinPickup = {
			count = 8,
			lifetime = 0.8,
			speed = { min = 50, max = 120 },
			color = { 1, 1, 0 }, -- Yellow
			size = { start = 4, finish = 1 },
			gravity = -100,
			spread = math.pi * 2,
		},

		walkDust = {
			count = 3,
			lifetime = 0.4,
			speed = { min = 10, max = 30 },
			color = { 0.8, 0.7, 0.6 }, -- Brown
			size = { start = 2, finish = 0 },
			gravity = 20,
			spread = math.pi / 3,
		},

		jumpDust = {
			count = 6,
			lifetime = 0.6,
			speed = { min = 20, max = 60 },
			color = { 0.9, 0.8, 0.7 },
			size = { start = 3, finish = 0 },
			gravity = 30,
			spread = math.pi,
		},

		playerDeath = {
			count = 20,
			lifetime = 2.0,
			speed = { min = 40, max = 150 },
			color = { 1, 0.5, 0.5 },
			size = { start = 4, finish = 1 },
			gravity = 80,
			spread = math.pi * 2,
		},
	}
end

function ParticleManager:emitWithColor(effectType, x, y, direction, customColor)
	local config = self.particleTypes[effectType]
	if not config then
		return
	end

	for i = 1, config.count do
		local angle = (direction or 0) + (math.random() - 0.5) * config.spread
		local speed = config.speed.min + math.random() * (config.speed.max - config.speed.min)

		-- Use custom color if provided
		local color = customColor or config.color

		local particle = {
			x = x + (math.random() - 0.5) * 10,
			y = y + (math.random() - 0.5) * 10,
			vx = math.cos(angle) * speed,
			vy = math.sin(angle) * speed,
			life = config.lifetime,
			maxLife = config.lifetime,
			color = { color[1], color[2], color[3], 1 },
			size = config.size.start,
			startSize = config.size.start,
			endSize = config.size.finish,
			gravity = config.gravity,
		}

		table.insert(self.particles, particle)
	end
end

function ParticleManager:emitConfetti(x, y)
	local colors = {
		{ 1, 0, 0 }, -- Red
		{ 0, 1, 0 }, -- Green
		{ 0, 0, 1 }, -- Blue
		{ 1, 1, 0 }, -- Yellow
		{ 1, 0, 1 }, -- Magenta
		{ 0, 1, 1 }, -- Cyan
	}

	for i = 1, 30 do
		local angle = math.random() * math.pi * 2
		local speed = 100 + math.random() * 100

		-- Random color for each particle
		local color = colors[math.random(#colors)]

		local particle = {
			x = x,
			y = y,
			vx = math.cos(angle) * speed,
			vy = math.sin(angle) * speed - 100, -- Launch upward
			life = 2.0,
			maxLife = 2.0,
			color = { color[1], color[2], color[3], 1 },
			size = 4,
			startSize = 4,
			endSize = 2,
			gravity = 150,
		}

		table.insert(self.particles, particle)
	end
end

function ParticleManager:emit(effectType, x, y, direction)
	local config = self.particleTypes[effectType]
	if not config then
		return
	end

	for i = 1, config.count do
		local angle = (direction or 0) + (math.random() - 0.5) * config.spread
		local speed = config.speed.min + math.random() * (config.speed.max - config.speed.min)

		local particle = {
			x = x + (math.random() - 0.5) * 10,
			y = y + (math.random() - 0.5) * 10,
			vx = math.cos(angle) * speed,
			vy = math.sin(angle) * speed,
			life = config.lifetime,
			maxLife = config.lifetime,
			color = { config.color[1], config.color[2], config.color[3], 1 },
			size = config.size.start,
			startSize = config.size.start,
			endSize = config.size.finish,
			gravity = config.gravity,
		}

		table.insert(self.particles, particle)
	end
end

function ParticleManager:update(dt)
	for i = #self.particles, 1, -1 do
		local p = self.particles[i]

		-- Update physics
		p.x = p.x + p.vx * dt
		p.y = p.y + p.vy * dt
		p.vy = p.vy + p.gravity * dt
		p.life = p.life - dt

		-- Update visual properties
		local lifePercent = p.life / p.maxLife
		p.color[4] = lifePercent -- Fade out
		p.size = p.startSize * lifePercent + p.endSize * (1 - lifePercent)

		-- Remove dead particles
		if p.life <= 0 then
			table.remove(self.particles, i)
		end
	end
end

function ParticleManager:draw()
	for _, p in ipairs(self.particles) do
		love.graphics.setColor(p.color)
		love.graphics.circle("fill", p.x, p.y, p.size)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function ParticleManager:clear()
	self.particles = {}
end

return ParticleManager
