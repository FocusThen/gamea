-- Libraries
Object = require("lib.classic.classic")
bump = require("lib.bump.bump")
baton = require("lib.baton.baton")
sti = require("lib.sti")
anim8 = require("lib.anim8.anim8")
flux = require("lib.flux.flux")
lume = require("lib.lume.lume")

-- Constants
local Constants = require("src.core.constants")

--- Load all files
local ResourceManager = require("src.game.resources")
require("src.game.loadMap")
---

stateMachine = require("src.states.stateMachine")
sceneEffects = require("src.systems.sceneEffects")
particleEffects = require("src.systems.particles")
shaderSystem = require("src.systems.shaders")
saveSystem = require("src.systems.saveSystem")

-- Display state
_G.screen_scale = 3
_G.offsetX = 0
_G.offsetY = 0

-- Game settings
_G.gameSettings = {
	masterVol = Constants.GAME.DEFAULT_MASTER_VOL,
	musicVol = Constants.GAME.DEFAULT_MUSIC_VOL,
	sfxVol = Constants.GAME.DEFAULT_SFX_VOL,
	gameWidth = Constants.GAME.WIDTH,
	gameHeight = Constants.GAME.HEIGHT,
}

-- Saved game state
_G.savedGame = {
	settings = _G.gameSettings,
	levelReached = 1,
} -- TODO: savegame

function love.load()
	worldCanvas = love.graphics.newCanvas(gameSettings.gameWidth, gameSettings.gameHeight)
	worldCanvas:setFilter("nearest", "nearest")

	resourceManager = ResourceManager.new()
	_G.resourceManager = resourceManager
	_G.sprites = resourceManager.sprites
	_G.fonts = resourceManager.fonts
	_G.sounds = resourceManager.sounds
	_G.music = resourceManager.music
	function playSound(entry)
		resourceManager:playEntry(entry)
	end

	-- Initialize physics world
	World = bump.newWorld(Constants.PHYSICS.CELL_SIZE)

	-- Initialize game systems
	stateMachine = stateMachine()
	sceneEffects = sceneEffects(worldCanvas)
	particleEffects = particleEffects()
	shaderSystem = shaderSystem()
	saveSystem = saveSystem()
	
	-- Load saved game if exists
	saveSystem:loadGame()

	updateScale()

	-- Start at intro screen
	if isDev then
		stateMachine:setState("levelSelect")
	else
		stateMachine:setState("intro")
	end
end

function love.update(dt)
	flux.update(dt)
	stateMachine:update(dt)

	--
	if isDev then
		require("lib.lurker.lurker").update()
	end
end

function love.draw()
	love.graphics.setCanvas(worldCanvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1, 1)
	---
	---
	stateMachine:draw()
	---
	---
	love.graphics.setColor(1, 1, 1, 1)
	sceneEffects:draw()
	---
	---
	if DEBUG and isDev then
		love.graphics.setColor(1, 0, 0, 0.5)
		local items, len = World:getItems()
		for i = 1, len do
			local item = items[i]
			local x, y, w, h = World:getRect(item)
			love.graphics.rectangle("line", x, y, w, h)
		end

		love.graphics.setColor(1, 1, 1, 1)
	end
	---
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1, 1)
	
	-- Apply shaders to canvas
	local processedCanvas = shaderSystem:apply(worldCanvas, gameSettings.gameWidth, gameSettings.gameHeight)
	
	-- Draw with shaders applied
	love.graphics.setBlendMode("alpha", "premultiplied")
	shaderSystem:draw(processedCanvas, offsetX, offsetY, screen_scale, screen_scale)
end

function love.keypressed(k)
	-- Allow ctrl+r for reset, and ctrl+q for quit
	if love.keyboard.isDown("lctrl", "rctrl") and isDev then
		if k == "r" then
			love.event.quit("restart")
		elseif k == "q" then
			love.event.quit()
		elseif k == "d" then
			DEBUG = not DEBUG
		end
	end

	stateMachine:keypressed(k)
end

function love.keyreleased(k)
	stateMachine:keyreleased(k)
end

function love.resize(w, h)
	updateScale()
end

function updateScale()
	local w, h = love.graphics.getDimensions()
	local sW = w / gameSettings.gameWidth
	local sH = h / gameSettings.gameHeight
	screen_scale = math.min(sW, sH)
	screen_scale = math.floor(screen_scale)

	-- Calculate centering offset
	_G.offsetX = math.floor((w - (gameSettings.gameWidth * screen_scale)) / 2)
	_G.offsetY = math.floor((h - (gameSettings.gameHeight * screen_scale)) / 2)
end

-- Use this for mouse/touch input
-- function screenToGame(x, y)
-- 	local gameX = (x - offsetX) / screen_scale
-- 	local gameY = (y - offsetY) / screen_scale
-- 	return gameX, gameY
-- end
