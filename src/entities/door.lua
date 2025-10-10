local Entity = require("src.entities.entity")
local Door = Entity:extend()

function Door:new(x, y)
	Door.super.new(self)
	self.x = x
	self.y = y
	self.w = 32
	self.h = 32
	self.kind = Entity_Kinds.DOOR

	--- Entity properties
	self.isOpen = false

	--- Entity Physics
	World:add(self, self.x, self.y, self.w, self.h)
end

function Door:update(dt) end

function Door:open()
	self.isOpen = true
	-- todo: spawn particles
end

function Door:draw()
	lg.setColor(CONFIG.COLORS.WHITE)
	if self.isOpen then
		lg.setColor(CONFIG.COLORS.BLUE)
		lg.rectangle("fill", self.x, self.y, self.w, self.h)
	else
		lg.rectangle("fill", self.x, self.y, self.w, self.h)
	end
end

function Door:filter(item, other)
	return "cross"
end

function Door:remove()
	self._remove = true
	self:removeFromWorld()
end

return Door
