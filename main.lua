-- Libraries
Object = require("lib.classic.classic")
bump = require("lib.bump.bump")
baton = require("lib.baton.baton")
sti = require("lib.sti")
anim8 = require("lib.anim8.anim8")
flux = require("lib.flux.flux")

--- Load all files
require("src.utils")
require("src.resources")
require("src.loadMap")
---

stateMachine = require("src.states.stateMachine")
sceneEffects = require("src.sceneEffects")

local canvas
local screen_scale = 3

function love.load()
	canvas = love.graphics.newCanvas(208, 224)
	canvas:setFilter("nearest", "nearest")
	--- World
	World = bump.newWorld(16)

	stateMachine = stateMachine()
	sceneEffects = sceneEffects(canvas)

	stateMachine:setState("title") --- Title screen
end

function love.update(dt)
	flux.update(dt)
	stateMachine:update(dt)
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1, 1)

	---
	stateMachine:draw()
	---
	sceneEffects:draw()
	---

	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(
		canvas,
		math.floor(love.graphics.getWidth() / 2 - canvas:getWidth() * screen_scale / 2),
		math.floor(love.graphics.getHeight() / 2 - canvas:getHeight() * screen_scale / 2),
		0,
		screen_scale,
		screen_scale
	)
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

	stateMachine:keypressed(k)
end

function love.keyreleased(k)
	stateMachine:keyreleased(k)
end

function love.resize(w, h)
	local sW = w / canvas:getWidth()
	local sH = h / canvas:getHeight()
	screen_scale = sW <= sH and sW or sH
	screen_scale = math.floor(screen_scale)
end
