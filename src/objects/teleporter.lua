local Constants = require("src.core.constants")
local teleporter = Object:extend()

function teleporter:new(x, y, props)
	self.x = x
	self.y = y
	self.width = props and props.width or Constants.TELEPORTER.WIDTH
	self.height = props and props.height or Constants.TELEPORTER.HEIGHT
	self.type = "teleporter"
	
	-- Properties from Tiled
	self.targetId = props and props.targetId or nil
	self.targetX = props and props.targetX or nil
	self.targetY = props and props.targetY or nil
	self.cooldown = props and props.cooldown or Constants.TELEPORTER.COOLDOWN
	self.transitionDuration = props and props.transitionDuration or Constants.TELEPORTER.TRANSITION_DURATION
	
	-- Target object (will be linked by loadLevel)
	self.targetTeleporter = nil
	
	-- State
	self.lastTeleportTime = 0
	self.teleporting = false
	
	-- Filter for collision detection (non-collidable)
	self.filter = function(item, other)
		return "cross"
	end
	
	World:add(self, self.x, self.y, self.width, self.height)
end

function teleporter:interact(player)
	-- Check cooldown
	local currentTime = love.timer.getTime()
	if currentTime - self.lastTeleportTime < self.cooldown then
		return
	end
	
	-- Don't teleport if already teleporting
	if self.teleporting then
		return
	end
	
	-- Determine destination
	local destX, destY
	if self.targetTeleporter then
		destX = self.targetTeleporter.x + self.targetTeleporter.width / 2 - player.width / 2
		destY = self.targetTeleporter.y - player.height
	elseif self.targetX and self.targetY then
		destX = self.targetX - player.width / 2
		destY = self.targetY - player.height
	else
		return -- No valid destination
	end
	
	-- Mark as teleporting
	self.teleporting = true
	self.lastTeleportTime = currentTime
	
	-- Hide player and disable movement during teleport
	player.visible = false
	player.teleporting = true
	
	-- Create rectangular particle explosion that moves to destination
	local startX = player.x
	local startY = player.y
	local destCenterX = destX + player.width / 2
	local destCenterY = destY + player.height / 2
	local startCenterX = startX + player.width / 2
	local startCenterY = startY + player.height / 2
	
	-- Create particles that explode from player and move to destination
	particleEffects:createTeleportParticles(
		startX, startY,
		destX, destY,
		player.width, player.height,
		0.4, -- duration
		function()
			-- When particles arrive, teleport player directly and make visible
			local teleX, teleY = World:move(player, destX, destY, player.filter)
			player.x = teleX
			player.y = teleY
			player.visible = true
			player.teleporting = false
			
			-- Reset teleporting flag
			self.teleporting = false
			if self.targetTeleporter then
				self.targetTeleporter.teleporting = false
			end
		end
	)
end

function teleporter:draw()
	-- Draw teleporter as a cyan rectangle with a glow effect
	love.graphics.setColor(0, 1, 1, 0.8)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0, 1, 1, 1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	
	-- Draw a simple indicator (circle) in the center
	local centerX = self.x + self.width / 2
	local centerY = self.y + self.height / 2
	love.graphics.setColor(1, 1, 1, 0.9)
	love.graphics.circle("fill", centerX, centerY, 2)
	love.graphics.setColor(1, 1, 1, 1)
end

return teleporter

