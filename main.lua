CONFIG = require("gameconfig")
DEBUG = false
lg = love.graphics

-- libraries
anime8 = require("lib.anim8.anim8")
bump = require("lib.bump.bump")
Object = require("lib.classic.classic")
flux = require("lib.flux.flux")
sti = require("lib.sti")
baton = require("lib.baton.baton")

-- Demo
e_player = require("src.entities.player")

-- Canvas setup
local canvas
local offsetX, offsetY = 0, 0

local entities = {}
local doors = {}
local timer = 0
local levelTimer = 0

local ground = Object:extend()
function ground:new(world)
	self.x = 0
	self.y = 150
	self.w = 500
	self.h = 1
	self.world = world
	self.kind = Entity_Kinds.GROUND
	self._remove = false
	self.ground = true
	World:add(self, self.x, self.y, self.w, self.h)
end

function ground:draw()
	lg.setColor(CONFIG.COLORS.WHITE)
	lg.rectangle("fill", self.x, self.y, self.w, self.h)
end

local updateEntities = function(dt)
	for i = #entities, 1, -1 do -- Iterate backwards for safe removal
		local e = entities[i]
		if e._remove == true then
			table.remove(entities, i)
		elseif type(e.update) == "function" then
			e:update(dt)
		end
	end
end

local function drawEntities()
	for i = 1, #entities do
		local e = entities[i]
		if type(e.draw) == "function" then
			e:draw()
		end
	end
end

local function addEntity(e)
	if e.isDoor then
		table.insert(doors, e)
	end
	table.insert(entities, e)
end

function love.load()
	math.randomseed(os.time())
	canvas = lg.newCanvas(CONFIG.pxWidth, CONFIG.pxHeight)
	canvas:setFilter("nearest", "nearest")

	-- Set default filter for other graphics
	lg.setDefaultFilter("nearest", "nearest")

	-- Set up window
	love.window.setMode(CONFIG.pxWidth * CONFIG.scale, CONFIG.pxHeight * CONFIG.scale, {
		resizable = true,
		vsync = true,
		minwidth = CONFIG.pxWidth,
		minheight = CONFIG.pxHeight,
	})

	updateScaleAndOffset()

	World = bump.newWorld()
	local p = e_player(50, 50)
	_G.player = p
	addEntity(p)
	local g = ground()
	addEntity(g)
end

function love.update(dt)
	timer = timer + dt
	levelTimer = levelTimer + dt
	-- flux.update(dt)
	updateEntities(dt)
end

function love.draw()
	lg.setCanvas(canvas)
	lg.clear(CONFIG.COLORS.BLACK)
	lg.setColor(CONFIG.COLORS.WHITE)

	drawEntities()

	lg.setCanvas()
	lg.clear(0, 0, 0)
	lg.setColor(1, 1, 1)
	lg.draw(canvas, offsetX, offsetY, 0, CONFIG.scale, CONFIG.scale)

	-- HIGH-RES OVERLAYS GO HERE!
	-- These are drawn at full window resolution

	-- Example 1: Semi-transparent overlay
	-- lg.setColor(0, 0, 0, 0.5)
	-- lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())

	-- Example 2: High-res UI panel
	-- local ww, wh = lg.getDimensions()
	-- lg.setColor(0.2, 0.2, 0.2, 0.9)
	-- lg.rectangle("fill", ww - 250, 0, 250, wh)
	-- lg.setColor(1, 1, 1)
	-- lg.print("High-Res UI Panel", ww - 240, 20)

	-- Example 3: Crisp text overlay (health, score, etc)
	-- lg.setColor(1, 1, 1)
	-- lg.printf("SCORE: 1000", 0, 20, ww, "center")

	-- Optional: Draw high-res UI/debug info here
	if DEBUG then
		lg.setColor(1, 1, 0)
		lg.print("FPS: " .. love.timer.getFPS(), 10, 10)
		lg.print(string.format("Scale: %.2f", CONFIG.scale), 10, 30)
		lg.print(string.format("Offset: %.0f, %.0f", offsetX, offsetY), 10, 50)
	end
end

function love.keypressed(k)
	-- Allow ctrl+r for reset, and ctrl+q for quit
	if love.keyboard.isDown("lctrl", "rctrl") then
		if k == "r" then
			love.event.quit("restart")
		elseif k == "q" then
			love.event.quit()
		end
	end

	-- Toggle debug with F3
	if k == "f3" then
		DEBUG = not DEBUG
	end

	-- Toggle fullscreen with F11
	if k == "f11" then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
end

function love.resize(w, h)
	updateScaleAndOffset()
end

function updateScaleAndOffset()
	local ww, wh = lg.getDimensions()
	local sx = ww / CONFIG.pxWidth
	local sy = wh / CONFIG.pxHeight
	CONFIG.scale = math.floor(math.min(sx, sy))

	offsetX = math.floor((ww - (CONFIG.pxWidth * CONFIG.scale)) / 2)
	offsetY = math.floor((wh - (CONFIG.pxHeight * CONFIG.scale)) / 2)
end

function setScale()
	updateScaleAndOffset()
end

function resetScale()
	CONFIG.scale = CONFIG.defaultScale
	updateScaleAndOffset()
end

function screenToGame(screenX, screenY)
	local gameX = (screenX - offsetX) / CONFIG.scale
	local gameY = (screenY - offsetY) / CONFIG.scale
	return gameX, gameY
end

function love.mousepressed(x, y, button)
	local gameX, gameY = screenToGame(x, y)

	if gameX >= 0 and gameX <= CONFIG.pxWidth and gameY >= 0 and gameY <= CONFIG.pxHeight then
		if DEBUG then
			print(string.format("Game click: %.1f, %.1f", gameX, gameY))
		end
	end
end
