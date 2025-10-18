local player = Object:extend()

function player:new(x, y)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 16

	self.speed = 100
	self.gravity = 1000
	self.jumpHeight = 200

	self.dashSpeed = 100
	self.dashHeight = 100

	self.dashing = false
	self.jumping = false
	self.grounded = false

	self.direction = 1
	self.facing = 1

	self.input = self:controls()
end

function player:update(dt)
	self.input:update()
end

function player:draw() end

function player:controls()
	return baton.new({
		controls = {
			left = { "key:left", "key:a", "axis:leftx-" },
			right = { "key:right", "key:d", "axis:leftx+" },
			jump = { "key:up", "key:w", "button:a", "axis:lefty-" },
      dash = { "key:space" }, -- TODO: dash key
			down = { "key:down", "key:s", "axis:lefty+" },
		},
		pairs = {
			move = { "left", "right" },
			-- jump = { "jump" },
			-- dash = { "dash" },
			-- down = { "down" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})
end

return player
