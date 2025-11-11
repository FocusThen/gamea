local sceneEffects = Object:extend()

local Constants = require("src.core.constants")

local WIPE_COLOR = { 20 / 255, 24 / 255, 46 / 255, 1 }
local FADE_COLOR = { WIPE_COLOR[1], WIPE_COLOR[2], WIPE_COLOR[3] }

function sceneEffects:new(canvas)
	self.canvas = canvas
	self.wipeEffectDuration = Constants.EFFECTS.WIPE_DURATION
	self.wipeProgress = { value = 0 } -- 0 to 1, where 0 = fully visible, 1 = fully wiped (wrapped in table for flux)
	self.wipeType = false -- false = wipe out, true = wipe in
	self.wipeTween = nil
	self.fadeTween = nil

	self.fadeEffectDuration = Constants.EFFECTS.FADE_DURATION
	self.fadeAlpha = { alpha = 0 }
end

function sceneEffects:setWipeIn()
	self.wipeProgress.value = 1 -- Start fully wiped (covered)
	self.wipeType = true
	self.wipeTween = flux.to(self.wipeProgress, self.wipeEffectDuration, { value = 0 })
		:oncomplete(function()
			self.wipeTween = nil
			self.wipeProgress.value = 0
		end)
end

function sceneEffects:setWipeOut()
	self.wipeProgress.value = 0 -- Start fully visible
	self.wipeType = false
	self.wipeTween = flux.to(self.wipeProgress, self.wipeEffectDuration, { value = 1 })
		:oncomplete(function()
			self.wipeTween = nil
			self.wipeProgress.value = 1
		end)
end

function sceneEffects:transitionToWithWipe(cb)
	if self.wipeTween then
		return
	end

	self:setWipeOut()
	self.wipeTween:oncomplete(function()
		if cb then
			cb()
		end
		self:setWipeIn()
	end)
end

function sceneEffects:setFadeIn()
	self.fadeAlpha = { alpha = 1 }
	self.fadeTween = flux.to(self.fadeAlpha, self.fadeEffectDuration, { alpha = 0 }):oncomplete(function()
		self.fadeTween = nil
	end)
end

function sceneEffects:setFadeOut()
	self.fadeAlpha = { alpha = 0 }
	self.fadeTween = flux.to(self.fadeAlpha, self.fadeEffectDuration, { alpha = 1 }):oncomplete(function()
		self.fadeTween = nil
	end)
end

function sceneEffects:transitionToWithFade(cb)
	if self.fadeTween then
		return
	end

	self:setFadeOut()
	self.fadeTween:oncomplete(function()
		if cb then
			cb()
		end
		self:setFadeIn()
	end)
end

function sceneEffects:drawWipePattern()
	local canvasWidth = self.canvas:getWidth()
	local canvasHeight = self.canvas:getHeight()
	
	-- Calculate the wipe edge position (pixel-perfect, rounded to nearest pixel)
	local wipeEdge = math.floor(canvasWidth * self.wipeProgress.value + 0.5)
	
	-- Simple smooth horizontal wipe - pixel perfect for any resolution
	-- Just draw a rectangle covering the appropriate portion of the screen
	if self.wipeType then
		-- Wipe in: reveal from left to right (draw from right edge moving left)
		-- At progress 1, screen is fully covered. At progress 0, screen is revealed.
		local coverWidth = canvasWidth * self.wipeProgress.value
		if coverWidth > 0 then
			love.graphics.rectangle("fill", canvasWidth - coverWidth, 0, coverWidth, canvasHeight)
		end
	else
		-- Wipe out: cover from left to right (draw from left edge moving right)
		-- At progress 0, screen is visible. At progress 1, screen is fully covered.
		if wipeEdge > 0 then
			love.graphics.rectangle("fill", 0, 0, wipeEdge, canvasHeight)
		end
	end
end

function sceneEffects:draw()
	if self.wipeTween then
		love.graphics.setColor(WIPE_COLOR[1], WIPE_COLOR[2], WIPE_COLOR[3], WIPE_COLOR[4])
		self:drawWipePattern()
		love.graphics.setColor(1, 1, 1, 1)
	end

	if self.fadeTween then
		love.graphics.setColor(FADE_COLOR[1], FADE_COLOR[2], FADE_COLOR[3], self.fadeAlpha.alpha)
		love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return sceneEffects
