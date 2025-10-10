local Entity = require("src.entities.entity")
local Coin = Entity:extend()
-- local Particle = require("entities.particle")

function Coin:initialize(x, y)
	Coin.super.new(self)
	self.x = x
	self.y = y
	self.w = 16
	self.h = 16
	self.kind = Entity_Kinds.COIN

	--- Entity properties
	self.isCollectible = true

	--- Entity Physics
	World:add(self, self.x, self.y, self.w, self.h)
end

function Coin:update(dt) end

function Coin:draw()
	lg.setColor(CONFIG.COLORS.YELLOW)
	lg.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Coin.filter(item, other)
	if other.kind == Entity_Kinds.PLAYER then
		return "cross"
	else
		return nil
	end
end

function Coin:collect()
	-- local x, y = self.x, self.y
	-- local p = Particle(x, y, "goldCollect")
	-- Game:addParticle(p)
	-- Game:collectGold()
	self:remove()
end

function Coin:remove()
	self._remove = true
	self:removeFromWorld()
end

return Coin
