local sceneEffects = Object:extend()

function sceneEffects:new(canvas)
	self.canvas = canvas
	self.wipeEffectDuration = 1
	self.wipePos = { x = 0, y = 0 }
	self.wipeImage1 = sprites.wipeImage1
	self.wipeImage1:setFilter("nearest", "nearest")
	self.wipeImage2 = sprites.wipeImage2
	self.wipeImage2:setFilter("nearest", "nearest")
	self.wipeType = false
	self.wipeTween = nil
	self.fadeTween = nil

	self.fadeEffectDuration = 3
	self.fadeAlpha = { alpha = 0 }
end

function sceneEffects:setWipeIn()
	self.wipePos.x = -100
	self.wipeType = true
	self.wipeTween = flux.to(self.wipePos, self.wipeEffectDuration, { x = self.canvas:getWidth() })
		:oncomplete(function()
			self.wipeTween = nil
		end)
end

function sceneEffects:setWipeOut()
	self.wipePos.x = 0 - self.wipeImage1:getWidth()
	self.wipeType = false
	self.wipeTween = flux.to(self.wipePos, self.wipeEffectDuration, { x = 0 }):oncomplete(function()
		self.wipeTween = nil
	end)
end

function sceneEffects:transitionToWithWipe(cb)
	if not self.wipeTween then
		self:setWipeOut()
		self.wipeTween:oncomplete(function()
			if cb then
				cb()
			end
			self:setWipeIn()
		end)
	end
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
	if not self.fadeTween then
		self:setFadeOut()
		self.fadeTween:oncomplete(function()
			if cb then
				cb()
			end
			self:setFadeIn()
		end)
	end
end

function sceneEffects:draw()
	if self.wipeTween then
		local image = self.wipeType and self.wipeImage2 or self.wipeImage1
		love.graphics.draw(image, self.wipePos.x, self.wipePos.y)
	end

	if self.fadeTween then
		love.graphics.setColor(20 / 255, 24 / 255, 46 / 255, self.fadeAlpha.alpha)
		love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return sceneEffects
