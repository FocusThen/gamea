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
	self.target = nil
	self.activeTeleport = nil
	
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
	local destinationObject = nil
	if self.target then
		destinationObject = self.target
		local targetX = destinationObject.x or self.targetX
		local targetY = destinationObject.y or self.targetY

		if not targetX or not targetY then
			return
		end

		destX = targetX + ((destinationObject.width or 0) / 2) - player.width / 2

		if destinationObject.type == "teleporter" then
			destY = targetY - player.height
		elseif destinationObject.height then
			destY = targetY + destinationObject.height - player.height
		else
			destY = targetY - player.height
		end
	elseif self.targetX and self.targetY then
		destX = self.targetX - player.width / 2
		destY = self.targetY - player.height
	else
		return -- No valid destination
	end

	-- Set teleporting state
	self.teleporting = true
	self.lastTeleportTime = currentTime
	if destinationObject and destinationObject.type == "teleporter" then
		destinationObject.teleporting = true
	end

	-- Prepare player for teleport
	player.controlLocked = true
	player.visible = false
	player.xVel = 0
	player.yVel = 0
	player.teleporting = true

	if World:hasItem(player) then
		World:remove(player)
	end

	local startCenterX = player.x + player.width / 2
	local startCenterY = player.y + player.height / 2
	local destCenterX = destX + player.width / 2
	local destCenterY = destY + player.height / 2

	local columns = 4
	local rows = 5
	local pieceWidth = player.width / columns
	local pieceHeight = player.height / rows
	local totalPieces = columns * rows
	local scatterRadius = math.max(player.width, player.height) * 1.5
	local scatterDuration = 0.18

	local dx = destCenterX - startCenterX
	local dy = destCenterY - startCenterY
	local travelDistance = math.sqrt(dx * dx + dy * dy)
	local baseTravel = self.transitionDuration or 0.3
	local travelDuration = math.max(baseTravel, travelDistance / 250)

	local teleportData = {
		player = player,
		destX = destX,
		destY = destY,
		totalPieces = totalPieces,
		completedPieces = 0,
		pieces = {},
		targetTeleporter = (destinationObject and destinationObject.type == "teleporter") and destinationObject or nil,
	}

	self.activeTeleport = teleportData

	local function onPieceArrived()
		teleportData.completedPieces = teleportData.completedPieces + 1
		if teleportData.completedPieces >= teleportData.totalPieces then
			self:_completeTeleport(teleportData)
		end
	end

	for row = 0, rows - 1 do
		for col = 0, columns - 1 do
			local piece = {
				cx = startCenterX,
				cy = startCenterY,
				width = pieceWidth,
				height = pieceHeight,
			}

			piece.finalCx = destX + (col + 0.5) * pieceWidth
			piece.finalCy = destY + (row + 0.5) * pieceHeight

			local angle = love.math.random() * math.pi * 2
			local radius = (love.math.random() * 0.6 + 0.4) * scatterRadius
			piece.midCx = startCenterX + math.cos(angle) * radius
			piece.midCy = startCenterY + math.sin(angle) * radius

			table.insert(teleportData.pieces, piece)

			flux.to(piece, scatterDuration, { cx = piece.midCx, cy = piece.midCy }):ease("quadout"):oncomplete(function()
				flux.to(piece, travelDuration, { cx = piece.finalCx, cy = piece.finalCy })
					:ease("quadout")
					:oncomplete(onPieceArrived)
			end)
		end
	end
end

function teleporter:_completeTeleport(teleportData)
	local player = teleportData.player

	player.x = teleportData.destX
	player.y = teleportData.destY
	player.xVel = 0
	player.yVel = 0
	player.visible = true
	player.controlLocked = false
	player.teleporting = false

	if not World:hasItem(player) then
		World:add(player, player.x, player.y, player.width, player.height)
	else
		World:update(player, player.x, player.y)
	end

	self.teleporting = false

	if teleportData.targetTeleporter then
		teleportData.targetTeleporter.teleporting = false
	end

	teleportData.pieces = nil
	self.activeTeleport = nil
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

	if self.activeTeleport and self.activeTeleport.pieces then
		love.graphics.setColor(0, 0, 0, 1)
		for _, piece in ipairs(self.activeTeleport.pieces) do
			love.graphics.rectangle(
				"fill",
				piece.cx - piece.width / 2,
				piece.cy - piece.height / 2,
				piece.width,
				piece.height
			)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return teleporter

