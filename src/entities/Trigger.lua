local BaseEntity = require("src.entities.BaseEntity")
local Trigger = BaseEntity:extend()

function Trigger:new(id, x, y, w, h, properties)
	Trigger.super.new(self, x, y, w, h)
	self.entity_id = id
	self.type = "trigger"
	self.zIndex = 10
	self.solid = false
	self.gravity = false
	self.visible = false

	properties = properties or {}
	self.targetId = properties.targetId.id
	self.triggerType = properties.triggerType or "none"
	self.isOneShot = properties.isOneShot or true
	self.delay = properties.delay or 0
	self.rearmTime = properties.rearmTime or 0

	-- Movement properties
	self.moveX = properties.moveX or 0
	self.moveY = properties.moveY or 0
	self.moveDuration = properties.moveDuration or 1
	self.moveEase = properties.moveEase or "linear" -- e.g., "quadinout", "elasticout"

	-- Internal state
	self.hasTriggered = false
	self.canRetrigger = true
	self.timer = 0
end

function Trigger:update(dt)
	Trigger.super.update(self, dt)

	if self.destroyed then
		return
	end

	-- Manage rearm timer
	if not self.isOneShot and self.hasTriggered and not self.canRetrigger then
		self.timer = self.timer + dt
		if self.timer >= self.rearmTime then
			self.canRetrigger = true
			self.timer = 0
			self.hasTriggered = false
		end
	end

	-- Check for player collision
	if not self.hasTriggered or (not self.isOneShot and self.canRetrigger) then
		local players = EM:getEntitiesByType("player")
		for _, player in ipairs(players) do
			if self:isCollidingWith(player) then
				self:activate()
				break
			end
		end
	end
end

function Trigger:activate()
	if self.hasTriggered and self.isOneShot then
		return
	end
	if not self.canRetrigger then
		return
	end

	self.hasTriggered = true
	self.canRetrigger = false
	self.timer = 0

	if self.delay > 0 then
		Flux.to(self, self.delay, { timer = self.delay }):oncomplete(function()
			self:performAction()
		end)
	else
		self:performAction()
	end
end

function Trigger:performAction()
	local targetEntity = self:findTargetEntity()

	if not targetEntity then
		print("Trigger: Could not find target entity with ID: " .. self.targetId)
		return
	end

	if self.triggerType == "move" then
		self:executeMovement(targetEntity)
	else
		print("Trigger: Unknown trigger type '" .. self.triggerType .. "'")
	end

	if self.isOneShot then
		self.destroyed = true
		EM:removeEntity(self)
	end
end

function Trigger:findTargetEntity()
	for _, entity in ipairs(EM.entities) do
		if entity.entity_id == self.targetId then
			return entity
		end
	end
	return nil
end

function Trigger:executeMovement(target)
	local targetX = target.x + self.moveX
	local targetY = target.y + self.moveY

	Flux.to(target, self.moveDuration, { x = targetX, y = targetY })
		:ease(self.moveEase)
		:onupdate(function()
			if target.solid and World:hasItem(target) then
				World:update(target, target.x, target.y)
			end
		end)
		:oncomplete(function()
			print("Target entity finished moving.")
		end)
end

function Trigger:draw()
	if self.visible then
		love.graphics.setColor(0, 1, 0, 0.3)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor(1, 1, 1, 1)
		-- Optionally draw target ID for debugging
		love.graphics.print("ID:" .. tostring(self.targetId), self.x, self.y - 15)
		love.graphics.print("Type:" .. self.triggerType, self.x, self.y - 5)
	end
end

return Trigger
