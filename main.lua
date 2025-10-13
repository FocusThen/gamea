-- libraries
anime8 = require("lib.anim8.anim8")
bump = require("lib.bump.bump")
flux = require("lib.flux.flux")
sti = require("lib.sti")
baton = require("lib.baton.baton")

function love.load()
	math.randomseed(os.time())
end

function love.update(dt) end

function love.draw() end

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
end
