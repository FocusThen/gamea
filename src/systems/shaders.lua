local shaders = Object:extend()

local function clamp01(value)
	return math.max(0, math.min(1, value))
end

local function loadShader(path)
	local ok, code = pcall(love.filesystem.read, path)
	if not ok or not code then
		return nil
	end

	local shaderOk, shader = pcall(love.graphics.newShader, code)
	if shaderOk then
		return shader
	end

	return nil
end

function shaders:new()
	self.enabled = {
		crt = true,
	}

	self.intensity = {
		crt = 1.0,
	}

	self.crtShader = nil
	self.colorTintShader = nil

	self:loadShaders()
end

function shaders:loadShaders()
	self.crtShader = loadShader("src/shaders/crt.glsl")
	self.colorTintShader = loadShader("src/shaders/colorTint.glsl")
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
		self.intensity[name] = clamp01(intensity)
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

