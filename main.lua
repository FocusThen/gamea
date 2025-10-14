function love.load()
end

function love.update(dt)
end

function love.draw()
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
end
