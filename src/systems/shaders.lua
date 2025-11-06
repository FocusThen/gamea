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
	self.colorTintShader = nil
	
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
	
	-- Load color tint shader
	local success, colorTintShaderCode = pcall(function() return love.filesystem.read("src/shaders/colorTint.glsl") end)
	if success and colorTintShaderCode then
		local shaderSuccess, shader = pcall(function() return love.graphics.newShader(colorTintShaderCode) end)
		if shaderSuccess then
			self.colorTintShader = shader
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

-- Apply color tint shader with specified color
-- Returns true if shader was applied, false otherwise
function shaders:applyColorTint(color)
	if self.colorTintShader and color then
		love.graphics.setShader(self.colorTintShader)
		self.colorTintShader:send("tintColor", {color.r, color.g, color.b})
		return true
	end
	return false
end

-- Remove color tint shader (restore default shader)
function shaders:removeColorTint()
	love.graphics.setShader()
end

return shaders

