local particles = require("src.particles")

local gameScene = Object:extend()

function gameScene:new()
	self.bindings = {
		["left"] = "left",
		["a"] = "left",
		["right"] = "right",
		["d"] = "right",
		["up"] = "jump",
		["w"] = "jump",
		["space"] = "dash",
		["down"] = "down",
		["r"] = "reset",
		["escape"] = "pause",
	}
	particles = particles()

	self.map = loadLevel("level_1")
end

function gameScene:update(dt)
	particles:update(dt)
end

function gameScene:draw()
	--- game draw codes
	self.map.tiled:draw()

	---
	particles:draw()
	---
end

function gameScene:keypressed(k)
	-- if self.bindings[k] == "pause" then
	--
	-- end
end

return gameScene
