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
local ScreenTransition = require("src.effects.ScreenTransition")
local ParticleManager = require("src.effects.ParticleManager")

_G.GSM = nil -- Game State Manager
_G.EM = nil -- Entity Manager
_G.AM = nil -- Asset Manager
_G.World = nil -- Bump physics world
_G.ST = nil -- Screen Transition
_G.PM = nil -- Particle Manager

-- Game configuration
_G.GameConfig = {
	window = {
		width = 1024,
		height = 768,
		title = "Game 1",
	},
	physics = {
		cellSize = 32,
		gravity = 1200,
	},
	visuals = {
		backgroundColor = { 0.2, 0.3, 0.4 }, -- RGB values (0-1) - Dark blue-gray
		-- Other color presets you can use:
		-- {0.1, 0.1, 0.15} - Almost black
		-- {0.15, 0.2, 0.3} - Dark blue
		-- {0.3, 0.2, 0.25} - Dark purple
		-- {0.2, 0.25, 0.2} - Dark green
	},
	debug = {
		enabled = false,
		showCollisions = false,
		showFPS = true,
	},
}

function love.load()
	math.randomseed(os.time())

	-- Setup window
	love.window.setTitle(GameConfig.window.title)
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Initialize core systems
	World = Bump.newWorld(GameConfig.physics.cellSize)

	-- Initialize managers
	GSM = GameStateManager()
	EM = EntityManager()
	AM = AssetManager()
	ST = ScreenTransition()
	PM = ParticleManager()

	-- Load initial assets
	AM:loadAssets()

	-- Start with menu state (or game state for testing)
	GSM:setState("game") -- Change to "menu" for menu system
end

function love.update(dt)
	-- Update tween library
	Flux.update(dt)
	Timer.update(dt)

	-- Update effects
	PM:update(dt)

	-- Update current game state
	GSM:update(dt)

	-- Update entity manager
	EM:update(dt)
end

function love.draw()
	if GameConfig.visuals and GameConfig.visuals.backgroundColor then
		love.graphics.clear(GameConfig.visuals.backgroundColor)
	end

	-- Draw current game state
	GSM:draw()

	-- Draw screen transition (always on top)
	ST:draw()

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
	elseif key == "f2" then
		GameConfig.debug.showCollisions = not GameConfig.debug.showCollisions
	end
end

function love.keyreleased(key)
	GSM:keyreleased(key)
end

function drawDebugInfo()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
	love.graphics.print("Entities: " .. EM:getEntityCount(), 10, 30)
	love.graphics.print("State: " .. GSM.currentState, 10, 50)
	love.graphics.print("F1: Toggle Debug, F2: Toggle Collisions", 10, love.graphics.getHeight() - 20)
end
