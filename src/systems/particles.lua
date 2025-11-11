local particles = Object:extend()
local Utils = require("src.core.utils")

function particles:new()
	self.effects = {}
	self.activeEffects = {}

	self:loadEffects()
end

function particles:update(dt)
	for i = #self.activeEffects, 1, -1 do
		if self.activeEffects[i].anim.status == "playing" then
			self.activeEffects[i].anim:update(dt)
		else
			table.remove(self.activeEffects, i)
		end
	end
end

function particles:draw()
	for _, effect in ipairs(self.activeEffects) do
		effect.anim:draw(effect.sheet, math.floor(effect.x), math.floor(effect.y))
	end
end

function particles:createEffect(effect, x, y, flip)
	local effectTemplate = self.effects[effect]
	if not effectTemplate then
		return
	end

	table.insert(
		self.activeEffects,
		{
			anim = Utils.deepCopy(effectTemplate.anim),
			sheet = effectTemplate.sheet,
			x = x,
			y = y,
		}
	)

	if flip then
		self.activeEffects[#self.activeEffects].anim:flipH()
	end
end

function particles:loadEffects()
	local atlas = (resourceManager and resourceManager.sprites) or sprites

	self.effects["jump"] = {}
	self.effects["jump"].sheet = atlas.particles.jump
	self.effects["jump"].sheet:setFilter("nearest", "nearest")
	local ejg = anim8.newGrid(20, 6, self.effects["jump"].sheet:getWidth(), self.effects["jump"].sheet:getHeight())
	self.effects["jump"].anim = anim8.newAnimation(ejg("1-7", 1), 0.075, "pauseAtEnd")

	self.effects["dash"] = {}
	self.effects["dash"].sheet = atlas.particles.smoke
	self.effects["dash"].sheet:setFilter("nearest", "nearest")
	local edg = anim8.newGrid(16, 10, self.effects["dash"].sheet:getWidth(), self.effects["dash"].sheet:getHeight())
	self.effects["dash"].anim = anim8.newAnimation(edg("1-6", 1), 0.1, "pauseAtEnd")

	self.effects["landing"] = {}
	self.effects["landing"].sheet = atlas.particles.landing
	self.effects["landing"].sheet:setFilter("nearest", "nearest")
	local elg =
		anim8.newGrid(16, 4, self.effects["landing"].sheet:getWidth(), self.effects["landing"].sheet:getHeight())
	self.effects["landing"].anim = anim8.newAnimation(elg("1-4", 1), 0.075, "pauseAtEnd")

	self.effects["boxLanding"] = {}
	self.effects["boxLanding"].sheet = atlas.particles.boxlanding
	self.effects["boxLanding"].sheet:setFilter("nearest", "nearest")
	local eblg =
		anim8.newGrid(28, 4, self.effects["boxLanding"].sheet:getWidth(), self.effects["boxLanding"].sheet:getHeight())
	self.effects["boxLanding"].anim = anim8.newAnimation(eblg("1-4", 1), 0.075, "pauseAtEnd")

	self.effects["walk"] = {}
	self.effects["walk"].sheet = atlas.particles.walking
	self.effects["walk"].sheet:setFilter("nearest", "nearest")
	local ewg = anim8.newGrid(10, 3, self.effects["walk"].sheet:getWidth(), self.effects["walk"].sheet:getHeight())
	self.effects["walk"].anim = anim8.newAnimation(ewg("1-6", 1), 0.1, "pauseAtEnd")
end

return particles
