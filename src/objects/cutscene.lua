local cutscene = Object:extend()

function cutscene:new(props)
	self.active = false
	self.currentStep = 1
	self.steps = props and props.steps or {}
	self.player = nil
	self.map = nil
	
	-- Camera state
	self.cameraX = 0
	self.cameraY = 0
	self.targetCameraX = 0
	self.targetCameraY = 0
	self.cameraSpeed = 100 -- pixels per second
	
	-- Text display
	self.currentText = nil
	self.textDuration = 0
	self.textTimer = 0
end

function cutscene:start(player, map)
	if self.active then
		return
	end
	
	self.active = true
	self.currentStep = 1
	self.player = player
	self.map = map
	
	-- Store initial camera position (if camera system exists)
	-- For now, we'll use a simple offset system
	
	self:executeStep()
end

function cutscene:stop()
	self.active = false
	self.currentStep = 1
	self.currentText = nil
	self.textTimer = 0
end

function cutscene:executeStep()
	if not self.active or self.currentStep > #self.steps then
		self:stop()
		return
	end
	
	local step = self.steps[self.currentStep]
	if not step then
		self:stop()
		return
	end
	
	local stepType = step.type or "wait"
	
	if stepType == "wait" then
		local duration = step.duration or 1.0
		flux.to({}, duration, {}):oncomplete(function()
			self.currentStep = self.currentStep + 1
			self:executeStep()
		end)
	elseif stepType == "moveCamera" then
		self.targetCameraX = step.x or 0
		self.targetCameraY = step.y or 0
		local distance = math.sqrt(
			(self.targetCameraX - self.cameraX) * (self.targetCameraX - self.cameraX) +
			(self.targetCameraY - self.cameraY) * (self.targetCameraY - self.cameraY)
		)
		local duration = step.duration or (distance / self.cameraSpeed)
		
		local cameraVars = { x = self.targetCameraX, y = self.targetCameraY }
		flux.to(self, duration, cameraVars):oncomplete(function()
			self.cameraX = self.targetCameraX
			self.cameraY = self.targetCameraY
			self.currentStep = self.currentStep + 1
			self:executeStep()
		end)
	elseif stepType == "showText" then
		self.currentText = step.text or ""
		self.textDuration = step.duration or 2.0
		self.textTimer = 0
		
		flux.to({}, self.textDuration, {}):oncomplete(function()
			self.currentText = nil
			self.textTimer = 0
			self.currentStep = self.currentStep + 1
			self:executeStep()
		end)
	elseif stepType == "moveObject" then
		if step.targetId and self.map and self.map.entitiesById then
			local targetId = step.targetId
			if type(targetId) == "table" and targetId.id then
				targetId = targetId.id
			end
			local target = self.map.entitiesById[targetId]
			if target then
				local endX = (step.x or target.x)
				local endY = (step.y or target.y)
				local duration = step.duration or 1.0
				
				flux.to(target, duration, { x = endX, y = endY }):oncomplete(function()
					if World:hasItem(target) then
						World:update(target, target.x, target.y)
					end
					self.currentStep = self.currentStep + 1
					self:executeStep()
				end)
			else
				self.currentStep = self.currentStep + 1
				self:executeStep()
			end
		else
			self.currentStep = self.currentStep + 1
			self:executeStep()
		end
	elseif stepType == "activateTrigger" then
		if step.targetId and self.map and self.map.entitiesById then
			local targetId = step.targetId
			if type(targetId) == "table" and targetId.id then
				targetId = targetId.id
			end
			local target = self.map.entitiesById[targetId]
			if target and target.activate then
				target:activate()
			end
		end
		
		local waitTime = step.wait or 0
		flux.to({}, waitTime, {}):oncomplete(function()
			self.currentStep = self.currentStep + 1
			self:executeStep()
		end)
	else
		-- Unknown step type, skip
		self.currentStep = self.currentStep + 1
		self:executeStep()
	end
end

function cutscene:update(dt)
	if not self.active then
		return
	end
	
	if self.currentText then
		self.textTimer = self.textTimer + dt
	end
end

function cutscene:draw()
	if not self.active then
		return
	end
	
	-- Draw text if active
	if self.currentText and self.textTimer < self.textDuration then
		local alpha = 1.0
		if self.textTimer > self.textDuration - 0.5 then
			-- Fade out in last 0.5 seconds
			alpha = (self.textDuration - self.textTimer) / 0.5
		end
		
		love.graphics.setColor(1, 1, 1, alpha)
		-- Draw text centered (would need font reference)
		-- For now, just a placeholder
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function cutscene:getCameraOffset()
	if not self.active then
		return 0, 0
	end
	return self.cameraX, self.cameraY
end

return cutscene

