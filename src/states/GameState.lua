local cam = require("src.utilities.cam")
local GameState = Class:extend()

function GameState:new()
	self.camera = nil
	self.map = nil
	self.player = nil
	self.cam = cam()
end

function GameState:enter()
	self.camera = self.cam.cam

	-- Load level using LevelManager
	if not LM:getCurrentLevelName() or LM:getCurrentLevelName() == "none" then
		-- Load first level or test level
		LM:loadLevel(LM.LEVELS.TEST, false) -- or LM.LEVELS.LEVEL_1
	end

	self.cam:setupCameraForMap()

	-- Camera will follow player (created by LevelManager)
	if _G.player and self.camera then
		self.camera:lookAt(_G.player.x + _G.player.w / 2, _G.player.y + _G.player.h / 2)
	end
end

function GameState:update(dt)
	self.cam:update(dt)
	-- Update Tiled map
	local map = LM:getCurrentMap()
	if map then
		map:update(dt)
	end
end

function GameState:draw()
	if not self.camera then
		return
	end

	self.camera:attach()

	-- Draw Tiled map
	local map = LM:getCurrentMap()
	if map then
		map:draw()
	end

	-- Draw all entities
	EM:draw()

	self.camera:detach()

	-- Draw UI (not affected by camera)
	self:drawUI()
end

function GameState:drawUI()
	love.graphics.setFont(AM:getFont("medium"))
	local levelText = "Level: " .. LM:getCurrentLevelIndex() .. "/" .. LM:getTotalLevels()
	love.graphics.print(levelText, 10, 10)
end

function GameState:keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "p" then
		GSM:setState("pause")
	elseif key == "r" then
		-- Restart current level with transition
		LM:reloadCurrentLevel(true)
	elseif key == "n" then
		-- Next level (for testing)
		LM:loadNextLevel(true)
	elseif key == "b" then
		-- Previous level (for testing)
		LM:loadPreviousLevel(true)
	elseif key == "1" then
		-- Quick load test level
		LM:loadLevel(LM.LEVELS.TEST, true)
	end
end

function GameState:exit()
	-- Cleanup when leaving state
end

function GameState:resize(w, h)
	self.cam:setupCameraForMap()
end

return GameState
