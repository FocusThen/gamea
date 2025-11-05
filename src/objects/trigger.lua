local trigger = Object:extend()

function trigger:new(x, y, props)
	self.x = x
	self.y = y
	self.width = props and props.width or 16
	self.height = props and props.height or 16
	self.type = "trigger"
	self.activated = false
	
	-- Properties from Tiled
	self.action = props and (props.action or "move") or "move" -- "move", "wait", "activate", "sequence", "cutscene", "timer"
	self.moveX = props and (props.moveX or 0) or 0
	self.moveY = props and (props.moveY or 0) or 0
	self.once = props and (props.once ~= false) or true -- Default to true
	self.targetId = props and props.targetId or nil -- ID of target object
	self.speed = props and props.speed or nil -- Movement speed in pixels per second
	self.duration = props and props.duration or nil -- Movement duration in seconds (used if speed is not set)
	self.delay = props and (props.delay or 0) or 0 -- Delay before action starts
	self.timerDelay = props and (props.timerDelay or 0) or 0 -- For timer-based triggers (activate after X seconds)
	
	-- For sequences
	self.sequence = props and props.sequence or nil -- Array of actions
	self.sequenceIndex = 1
	self.sequenceActive = false
	
	-- For cutscenes
	self.cutscene = props and props.cutscene or nil -- Cutscene data
	
	-- Target object (will be linked by loadLevel)
	self.target = nil
	
	-- Tweening
	self.isMoving = false
	self.startX = nil
	self.startY = nil
	self.endX = nil
	self.endY = nil
	
	-- Timer state
	self.timer = 0
	self.timerActive = false
	
	-- Delay state
	self.delayTimer = 0
	self.delayActive = false
	
	-- Add to world but as non-collidable (cross response)
	World:add(self, self.x, self.y, self.width, self.height)
	
	-- Start timer if this is a timer-based trigger
	if self.action == "timer" and self.timerDelay > 0 then
		self.timerActive = true
	end
end

function trigger:activate()
	if self.once and self.activated and self.action ~= "timer" then
		return
	end
	
	self.activated = true
	
	-- Handle delay
	if self.delay > 0 then
		self.delayActive = true
		self.delayTimer = 0
		return
	end
	
	-- Execute action based on type
	if self.action == "move" then
		self:doMove()
	elseif self.action == "wait" then
		-- Wait is handled in sequence
	elseif self.action == "activate" then
		self:doActivate()
	elseif self.action == "sequence" then
		self:doSequence()
	elseif self.action == "cutscene" then
		self:doCutscene()
	end
end

function trigger:doMove()
	-- Move target object smoothly if it exists
	if self.target then
		self.startX = self.target.x or 0
		self.startY = self.target.y or 0
		self.endX = self.startX + self.moveX
		self.endY = self.startY + self.moveY
		
		-- Calculate duration based on speed or use provided duration
		local distance = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
		local movementDuration
		if self.speed and self.speed > 0 then
			movementDuration = distance / self.speed
		else
			movementDuration = self.duration or 0.5
		end
		
		self.isMoving = true
		
		-- Create tween for smooth movement (both x and y together)
		local tweenVars = { x = self.endX }
		if self.target.y then
			tweenVars.y = self.endY
		end
		
		flux.to(self.target, movementDuration, tweenVars):oncomplete(function()
			self.isMoving = false
			-- Final physics world update
			if World:hasItem(self.target) then
				World:update(self.target, self.target.x, self.target.y or self.endY)
			end
		end)
	end
end

function trigger:doActivate()
	-- Activate another trigger or object
	if self.target and self.target.activate then
		self.target:activate()
	elseif self.target and self.target.interact then
		-- For objects that use interact instead of activate
		-- This would need player reference, but we'll handle it differently
	end
end

function trigger:doSequence()
	if not self.sequence or type(self.sequence) ~= "table" then
		return
	end
	
	self.sequenceActive = true
	self.sequenceIndex = 1
	self:executeSequenceStep()
end

function trigger:executeSequenceStep()
	if not self.sequenceActive or self.sequenceIndex > #self.sequence then
		self.sequenceActive = false
		return
	end
	
	local step = self.sequence[self.sequenceIndex]
	if not step then
		self.sequenceActive = false
		return
	end
	
	local stepAction = step.action or "move"
	local stepDelay = step.delay or 0
	
	if stepAction == "move" then
		-- Store original move values temporarily
		local origMoveX = self.moveX
		local origMoveY = self.moveY
		local origSpeed = self.speed
		local origDuration = self.duration
		
		-- Apply step values
		self.moveX = step.moveX or 0
		self.moveY = step.moveY or 0
		self.speed = step.speed or self.speed
		self.duration = step.duration or self.duration
		
		-- Execute move
		self:doMove()
		
		-- Restore original values
		self.moveX = origMoveX
		self.moveY = origMoveY
		self.speed = origSpeed
		self.duration = origDuration
		
		-- Wait for movement to complete plus delay
		local totalDelay = (step.duration or 0.5) + stepDelay
		flux.to({}, totalDelay, {}):oncomplete(function()
			self.sequenceIndex = self.sequenceIndex + 1
			self:executeSequenceStep()
		end)
	elseif stepAction == "wait" then
		flux.to({}, stepDelay, {}):oncomplete(function()
			self.sequenceIndex = self.sequenceIndex + 1
			self:executeSequenceStep()
		end)
		elseif stepAction == "activate" then
		-- Activate target
		if step.targetId and self.map and self.map.entitiesById then
			local targetId = step.targetId
			-- Handle both number and table format from Tiled
			if type(targetId) == "table" and targetId.id then
				targetId = targetId.id
			end
			local target = self.map.entitiesById[targetId]
			if target and target.activate then
				target:activate()
			end
		end
		
		flux.to({}, stepDelay, {}):oncomplete(function()
			self.sequenceIndex = self.sequenceIndex + 1
			self:executeSequenceStep()
		end)
	end
end

function trigger:doCutscene()
	-- Cutscene handling
	if self.cutscene then
		-- Create cutscene object if it's a table of steps
		if type(self.cutscene) == "table" then
			local Cutscene = require("src.objects.cutscene")
			local cutsceneObj = Cutscene({ steps = self.cutscene })
			
			-- Get player and map from context
			-- This assumes we have access to the game state
			-- For now, we'll need to pass these through
			if self.gameState then
				local player = self.gameState.player
				local map = self.gameState.map
				if player and map then
					cutsceneObj:start(player, map)
					-- Store reference for cleanup
					self.activeCutscene = cutsceneObj
				end
			end
		end
	end
end

function trigger:interact(player)
	if not self.once or not self.activated then
		self:activate()
	elseif self.action == "timer" then
		-- Timer triggers can be reactivated
		self:activate()
	end
end

function trigger:update(dt)
	-- Update physics world during smooth movement
	if self.isMoving and self.target and World:hasItem(self.target) then
		World:update(self.target, self.target.x, self.target.y)
	end
	
	-- Handle delay
	if self.delayActive then
		self.delayTimer = self.delayTimer + dt
		if self.delayTimer >= self.delay then
			self.delayActive = false
			self.delayTimer = 0
			-- Execute action after delay
			if self.action == "move" then
				self:doMove()
			elseif self.action == "activate" then
				self:doActivate()
			elseif self.action == "sequence" then
				self:doSequence()
			elseif self.action == "cutscene" then
				self:doCutscene()
			end
		end
	end
	
	-- Handle timer-based activation
	if self.timerActive then
		self.timer = self.timer + dt
		if self.timer >= self.timerDelay then
			self.timerActive = false
			self.timer = 0
			self:activate()
		end
	end
end

function trigger:draw()
	-- Triggers are invisible by default
	-- Only draw when DEBUG is enabled
	if DEBUG then
		love.graphics.setColor(1, 1, 0, 0.3)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return trigger
