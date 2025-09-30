--libs
Class = require("libs.classic.classic")
Bump = require("libs.bump.bump")
Anim8 = require("libs.anim8.anim8")
Flux = require("libs.flux.flux")
Sti = require("libs.sti")
Vector = require("libs.hump.vector")
Timer = require("libs.hump.timer")
Camera = require("libs.hump.camera")

-- Load core systems
local GameStateManager = require("src.core.GameStateManager")
local EntityManager = require("src.core.EntityManager")
local AssetManager = require("src.core.AssetManager")
local LevelManager = require("src.core.LevelManager")


-- Game configuration
_G.GameConfig = {
	window = {
		width = 1024,
		height = 768,
	},
	physics = {
		gravity = 1200,
	},
	debug = {
		enabled = false,
		showCollisions = false,
	},
}

function love.load()
	math.randomseed(os.time())

	-- Setup window
	love.graphics.setDefaultFilter("nearest", "nearest")

  World = Bump.newWorld(32)

	-- Initialize managers
	GSM = GameStateManager()
	EM = EntityManager()
	AM = AssetManager()
  LM = LevelManager()

	-- Load initial assets
	AM:loadAssets()

	-- Start with menu state (or game state for testing)
	GSM:setState("menu") -- Change to "menu" for menu system
end

function love.update(dt)
	-- Update tween library
	-- Flux.update(dt)
  Timer.update(dt)

	-- -- Update effects
	-- PM:update(dt)

	-- Update current game state
	GSM:update(dt)

	-- Update entity manager
	EM:update(dt)
end

function love.draw()
	love.graphics.clear({ 0.2, 0.3, 0.4 })

	-- Draw current game state
	GSM:draw()

	-- Draw debug info if enabled
	if GameConfig.debug.enabled then
		drawDebugInfo()
	end
end

function love.keypressed(key)
	GSM:keypressed(key)

	-- Global debug toggle
	if key == "f1" then
		GameConfig.debug.enabled = not GameConfig.debug.enabled
	end
end

function love.keyreleased(key)
	GSM:keyreleased(key)
end

function love.resize(w, h)
    GSM:resize(w, h)
end

function drawDebugInfo()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
	love.graphics.print("Entities: " .. EM:getEntityCount(), 10, 30)
	love.graphics.print("State: " .. GSM.currentState, 10, 50)
end
