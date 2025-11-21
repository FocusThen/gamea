--[[
	Trigger System
	
	Handles interactive triggers that can move, scale, activate, and sequence actions
	on target entities when activated by player collision or timers.
	
	Action Types:
	- "move": Smoothly move target entity (requires moveX, moveY)
	- "scale": Smoothly scale target entity (requires scale properties)
	- "activate": Activate another trigger/object
	- "sequence": Execute multiple actions in sequence
	- "cutscene": Trigger a cutscene
	- "timer": Auto-activate after delay
	
	See TRIGGER_SYSTEM.md for detailed developer documentation.
	See TILED_GUIDE.md for level designer usage guide.
]]

local trigger = Object:extend()

function trigger:new(x, y, width, height, props)
	self.x = x
	self.y = y
	self.width = width or 16
	self.height = height or 16
	self.type = "trigger"
	self.activated = false

	-- Properties from Tiled
	self.action = props and (props.action or "move") or "move" -- "move", "scale", "wait", "activate", "sequence", "cutscene", "timer"
	self.moveX = props and (props.moveX or 0) or 0
	self.moveY = props and (props.moveY or 0) or 0
	self.once = props and (props.once ~= false) or true -- Default to true
	self.targetId = props and props.targetId or nil -- ID of target object
	self.speed = props and props.speed or nil -- Movement speed in pixels per second
	self.duration = props and props.duration or nil -- Movement duration in seconds (used if speed is not set)
	self.delay = props and (props.delay or 0) or 0 -- Delay before action starts
	self.timerDelay = props and (props.timerDelay or 0) or 0 -- For timer-based triggers (activate after X seconds)
	
	-- Scaling properties
	self.scale = props and props.scale or nil -- Uniform scale target (e.g., 0.5 to shrink to half size, 2.0 to double)
	self.scaleX = props and props.scaleX or nil -- X scale target (non-uniform scaling)
	self.scaleY = props and props.scaleY or nil -- Y scale target (non-uniform scaling)
	self.startScale = props and props.startScale or nil -- Starting scale (if not provided, uses current scale of 1.0)
	self.startScaleX = props and props.startScaleX or nil -- Starting X scale
	self.startScaleY = props and props.startScaleY or nil -- Starting Y scale
	self.endScale = props and props.endScale or nil -- Ending scale (if not provided, uses scale property)
	self.endScaleX = props and props.endScaleX or nil -- Ending X scale
	self.endScaleY = props and props.endScaleY or nil -- Ending Y scale

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
	self.isScaling = false
	self.startX = nil
	self.startY = nil
	self.endX = nil
	self.endY = nil
	
	-- Scaling state
	self.scaleProgress = 0
	self.scaleTween = nil
	self.originalWidth = nil
	self.originalHeight = nil
	self.currentScaleX = 1.0
	self.currentScaleY = 1.0
	self.targetScaleX = 1.0
	self.targetScaleY = 1.0

	-- Timer state
	self.timer = 0
	self.timerActive = false

	-- Delay state
	self.delayTimer = 0
	self.delayActive = false

	self.moveProgress = 0
	self.moveTween = nil
	self.lastTargetX = nil
	self.lastTargetY = nil
	self.platformFriction = 0

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
	elseif self.action == "scale" then
		self:doScale()
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
		self.moveProgress = 0
		if self.moveTween then
			self.moveTween:stop()
		end
		self.moveTween = flux.to(self, movementDuration, { moveProgress = 1 }):oncomplete(function()
			self.isMoving = false
			self.moveTween = nil
			self.moveProgress = 1
			self:updateMovingTarget(true)
		end)
		self.lastTargetX = self.startX
		self.lastTargetY = self.startY
		self:updateMovingTarget(true)
	end
end

function trigger:doScale()
	-- Scale target object smoothly if it exists
	if not self.target then
		return
	end
	
	-- Store original dimensions (base size, before any scaling)
	-- If target has been scaled before, we need to find the base size
	-- For now, we'll use current dimensions divided by current scale, or just store current if first time
	if not self.originalWidth or not self.originalHeight then
		local currentScaleX = self.target.scaleX or 1.0
		local currentScaleY = self.target.scaleY or 1.0
		-- If already scaled, try to get base size
		if currentScaleX ~= 1.0 or currentScaleY ~= 1.0 then
			self.originalWidth = (self.target.width or 16) / currentScaleX
			self.originalHeight = (self.target.height or 16) / currentScaleY
		else
			self.originalWidth = self.target.width or 16
			self.originalHeight = self.target.height or 16
		end
	end
	
	-- Get current scale from target, or default to 1.0
	local currentTargetScaleX = self.target.scaleX or 1.0
	local currentTargetScaleY = self.target.scaleY or 1.0
	
	-- Determine start scales (use explicit start, or current scale, or default to 1.0)
	local startSX = self.startScaleX or self.startScale or currentTargetScaleX
	local startSY = self.startScaleY or self.startScale or currentTargetScaleY
	
	-- Determine end scales
	-- Priority: endScaleX/Y > scaleX/Y (relative) > endScale (uniform) > scale (uniform)
	local endSX, endSY
	
	if self.endScaleX then
		-- Absolute target X scale
		endSX = self.endScaleX
	elseif self.scaleX then
		-- Relative change in X scale
		endSX = startSX + self.scaleX
	elseif self.endScale then
		-- Absolute uniform target scale
		endSX = self.endScale
	elseif self.scale then
		-- Relative uniform scale change
		endSX = startSX + (self.scale - 1.0)
	else
		-- No scale specified, keep current
		endSX = startSX
	end
	
	if self.endScaleY then
		-- Absolute target Y scale
		endSY = self.endScaleY
	elseif self.scaleY then
		-- Relative change in Y scale
		endSY = startSY + self.scaleY
	elseif self.endScale then
		-- Absolute uniform target scale
		endSY = self.endScale
	elseif self.scale then
		-- Relative uniform scale change
		endSY = startSY + (self.scale - 1.0)
	else
		-- No scale specified, keep current
		endSY = startSY
	end
	
	-- If only uniform scale is provided, apply to both axes
	if self.scale and not self.scaleX and not self.scaleY and not self.endScaleX and not self.endScaleY and not self.endScale then
		endSX = self.scale
		endSY = self.scale
	end
	
	self.currentScaleX = startSX
	self.currentScaleY = startSY
	self.targetScaleX = endSX
	self.targetScaleY = endSY
	
	-- Calculate duration (use same logic as movement)
	local scaleDuration = self.duration or 0.5
	
	self.isScaling = true
	self.scaleProgress = 0
	if self.scaleTween then
		self.scaleTween:stop()
	end
	self.scaleTween = flux.to(self, scaleDuration, { scaleProgress = 1 }):oncomplete(function()
		self.isScaling = false
		self.scaleTween = nil
		self.scaleProgress = 1
		self:updateScalingTarget(true)
	end)
	self:updateScalingTarget(true)
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
	elseif stepAction == "scale" then
		-- Store original scale values temporarily
		local origScale = self.scale
		local origScaleX = self.scaleX
		local origScaleY = self.scaleY
		local origStartScale = self.startScale
		local origStartScaleX = self.startScaleX
		local origStartScaleY = self.startScaleY
		local origEndScale = self.endScale
		local origEndScaleX = self.endScaleX
		local origEndScaleY = self.endScaleY
		local origDuration = self.duration

		-- Apply step values
		self.scale = step.scale or self.scale
		self.scaleX = step.scaleX or self.scaleX
		self.scaleY = step.scaleY or self.scaleY
		self.startScale = step.startScale or self.startScale
		self.startScaleX = step.startScaleX or self.startScaleX
		self.startScaleY = step.startScaleY or self.startScaleY
		self.endScale = step.endScale or self.endScale
		self.endScaleX = step.endScaleX or self.endScaleX
		self.endScaleY = step.endScaleY or self.endScaleY
		self.duration = step.duration or self.duration

		-- Execute scale
		self:doScale()

		-- Restore original values
		self.scale = origScale
		self.scaleX = origScaleX
		self.scaleY = origScaleY
		self.startScale = origStartScale
		self.startScaleX = origStartScaleX
		self.startScaleY = origStartScaleY
		self.endScale = origEndScale
		self.endScaleX = origEndScaleX
		self.endScaleY = origEndScaleY
		self.duration = origDuration

		-- Wait for scaling to complete plus delay
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

function trigger:updateMovingTarget(force)
	if not self.target then
		return
	end

	local goalX = self.startX + self.moveX * self.moveProgress
	local goalY = self.startY + self.moveY * self.moveProgress

	local prevX = self.lastTargetX or (self.target.x or goalX)
	local prevY = self.lastTargetY or (self.target.y or goalY)

	if not force and math.abs(goalX - prevX) < 0.0001 and math.abs(goalY - prevY) < 0.0001 then
		return
	end

	local dx = goalX - prevX
	local dy = goalY - prevY

	if dx == 0 and dy == 0 and not force then
		self.lastTargetX = goalX
		self.lastTargetY = goalY
		return
	end

	local inWorld = World:hasItem(self.target)
	if inWorld then
		World:update(self.target, goalX, goalY)
	end

	if self.target.x then
		self.target.x = goalX
	end
	if self.target.y then
		self.target.y = goalY
	end

	local handled = {}
	local function pushRider(other)
		if not other or handled[other] then
			return
		end
		if other.type ~= "player" and other.type ~= "box" then
			return
		end
		handled[other] = true

		local riderDX = dx * self.platformFriction
		local riderDY = dy

		local goalOX = other.x + riderDX
		local goalOY = other.y + riderDY
		local oActualX, oActualY = World:move(other, goalOX, goalOY, other.filter)
		other.x = oActualX
		if other.y then
			other.y = oActualY
		end
		if other.type == "player" and dy < 0 and other.yVel and other.yVel > 0 then
			other.yVel = 0
		end
	end

	if inWorld then
		local _, _, cols, len = World:check(self.target, goalX, goalY, function(item, other)
			if other == self.target then
				return nil
			end
			if other.type == "player" or other.type == "box" then
				return "cross"
			end
			return nil
		end)

		if len and len > 0 then
			for i = 1, len do
				pushRider(cols[i].other)
			end
		end
	end

	local width = self.target.width or 0
	local height = self.target.height or 0
	if inWorld and width > 0 and height > 0 then
		local expand = 1
		local riders, ridersLen = World:queryRect(goalX - expand, goalY - expand, width + expand * 2, height + expand * 2, function(item)
			return item ~= self.target and (item.type == "player" or item.type == "box")
		end)
		if ridersLen and ridersLen > 0 then
			for i = 1, ridersLen do
				pushRider(riders[i])
			end
		end
	end

	self.lastTargetX = goalX
	self.lastTargetY = goalY
end

function trigger:updateScalingTarget(force)
	if not self.target then
		return
	end
	
	-- Calculate current scale based on progress
	local currentSX = self.currentScaleX + (self.targetScaleX - self.currentScaleX) * self.scaleProgress
	local currentSY = self.currentScaleY + (self.targetScaleY - self.currentScaleY) * self.scaleProgress
	
	-- Calculate new dimensions
	local newWidth = (self.originalWidth or (self.target.width or 16)) * currentSX
	local newHeight = (self.originalHeight or (self.target.height or 16)) * currentSY
	
	-- Store scale on target for reference
	self.target.scaleX = currentSX
	self.target.scaleY = currentSY
	self.target.scale = currentSX -- For uniform scaling reference
	
	-- Update target dimensions
	local oldWidth = self.target.width or 16
	local oldHeight = self.target.height or 16
	
	-- Only update if dimensions changed significantly
	if not force and math.abs(newWidth - oldWidth) < 0.01 and math.abs(newHeight - oldHeight) < 0.01 then
		return
	end
	
	-- Calculate center point to maintain position during scaling
	local centerX = self.target.x + oldWidth / 2
	local centerY = self.target.y + oldHeight / 2
	
	-- Update dimensions
	self.target.width = newWidth
	self.target.height = newHeight
	
	-- Adjust position to keep center point fixed
	local newX = centerX - newWidth / 2
	local newY = centerY - newHeight / 2
	
	-- Update physics world
	local inWorld = World:hasItem(self.target)
	if inWorld then
		World:update(self.target, newX, newY, newWidth, newHeight)
	end
	
	-- Update position
	if self.target.x then
		self.target.x = newX
	end
	if self.target.y then
		self.target.y = newY
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
	if self.isMoving then
		self:updateMovingTarget()
	end
	
	-- Update physics world during smooth scaling
	if self.isScaling then
		self:updateScalingTarget()
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
			elseif self.action == "scale" then
				self:doScale()
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
