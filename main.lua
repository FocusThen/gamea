-- Libraries
Object = require("lib.classic.classic")
bump = require("lib.bump.bump")
baton = require("lib.baton.baton")
sti = require("lib.sti")
anim8 = require("lib.anim8.anim8")
flux = require("lib.flux.flux")
lume = require("lib.lume.lume")

--- Load all files
require("src.utils")
require("src.resources")
require("src.loadMap")
---

stateMachine = require("src.states.stateMachine")
sceneEffects = require("src.sceneEffects")
particleEffects = require("src.particles")

_G.screen_scale = 3
_G.gameSettings = {
	masterVol = 1,
	musicVol = 0.7,
	sfxVol = 0.5,
}
_G.savedGame = {
	settings = _G.gameSettings,
	levelReached = 1,
} -- TODO: savegame

function love.load()
	worldCanvas = love.graphics.newCanvas(208, 224)
	worldCanvas:setFilter("nearest", "nearest")
	--- World
	World = bump.newWorld(16)

	stateMachine = stateMachine()
	sceneEffects = sceneEffects(worldCanvas)
	particleEffects = particleEffects()

	--- Demo purpose
	stateMachine:setState("levelSelect") --- Title screen
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
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(
		worldCanvas,
		math.floor(love.graphics.getWidth() / 2 - worldCanvas:getWidth() * screen_scale / 2),
		math.floor(love.graphics.getHeight() / 2 - worldCanvas:getHeight() * screen_scale / 2),
		0,
		screen_scale,
		screen_scale
	)
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
	local sW = w / worldCanvas:getWidth()
	local sH = h / worldCanvas:getHeight()
	screen_scale = sW <= sH and sW or sH
	screen_scale = math.floor(screen_scale)
end
