local shaders = Object:extend()

function shaders:new()
	self.enabled = {
		crt = true, -- Enabled by default
	}
	
	self.intensity = {
		crt = 1.0,
	}
	
	-- Load shaders
	self.crtShader = nil
	
	self:loadShaders()
end

function shaders:loadShaders()
	-- Load CRT shader
	local success, crtShaderCode = pcall(function() return love.filesystem.read("src/shaders/crt.glsl") end)
	if success and crtShaderCode then
		local shaderSuccess, shader = pcall(function() return love.graphics.newShader(crtShaderCode) end)
		if shaderSuccess then
			self.crtShader = shader
		end
	end
end

function shaders:toggle(name)
	if self.enabled[name] ~= nil then
		self.enabled[name] = not self.enabled[name]
	end
end

function shaders:setEnabled(name, enabled)
	if self.enabled[name] ~= nil then
		self.enabled[name] = enabled
	end
end

function shaders:setIntensity(name, intensity)
	if self.intensity[name] ~= nil then
		self.intensity[name] = math.max(0, math.min(1, intensity))
	end
end

function shaders:apply(canvas, width, height)
	-- CRT shader is applied during final draw, so just return canvas
	return canvas
end

function shaders:draw(canvas, x, y, scaleX, scaleY)
	if not canvas then
		return
	end
	
	-- Apply CRT shader if enabled
	if self.enabled.crt and self.crtShader then
		love.graphics.setShader(self.crtShader)
		self.crtShader:send("time", love.timer.getTime())
		self.crtShader:send("intensity", self.intensity.crt)
	end
	
	love.graphics.draw(canvas, x, y, 0, scaleX, scaleY)
	
	if self.enabled.crt then
		love.graphics.setShader()
	end
end

return shaders

