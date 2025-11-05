local levelSelectScene = Object:extend()

_G.numOfLevels = 2

function levelSelectScene:new()
	self.bindings = baton.new({
		controls = {
			back = { "key:escape", "button:b" },
			select = {
				"key:space",
				"key:return",
				"key:z",
				"button:a",
			},
			left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
			right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
			up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
			down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
		},
		joystick = love.joystick.getJoysticks()[1],
	})

	self.selected = 1
end

function levelSelectScene:update(dt)
	self.bindings:update()

	if self.bindings:pressed("back") then
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("main_menu")
		end)
	elseif self.bindings:pressed("select") then
		sceneEffects:transitionToWithWipe(function()
			stateMachine:setState("game", {
				map = loadLevel("level_" .. self.selected),
			})
		end)
	elseif self.bindings:pressed("left") then
		self.selected = self.selected - 1
		playSound(sounds.select)
	elseif self.bindings:pressed("right") then
		self.selected = self.selected + 1
		playSound(sounds.select)
	elseif self.bindings:pressed("up") then
		self.selected = self.selected - 6
		playSound(sounds.select)
	elseif self.bindings:pressed("down") then
		self.selected = self.selected + 6
		playSound(sounds.select)
	end

	if self.selected > numOfLevels then
		self.selected = numOfLevels
	end
	if self.selected > savedGame.levelReached and not isDev then
		self.selected = savedGame.levelReached
	end
	if self.selected < 1 then
		self.selected = 1
	end
end

function levelSelectScene:draw()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.draw(sprites.ui.levelSelect, 0, 0)

	love.graphics.setColor(43 / 255, 43 / 255, 69 / 255, 1)
	love.graphics.print(
		"Level Select",
		fonts.default,
		worldCanvas:getWidth() / 2 - math.floor(fonts.default:getWidth("Level Select") / 2),
		8
	)

	love.graphics.setColor(146 / 255, 232 / 255, 192 / 255, 1)
	love.graphics.print(
		"Arrow keys to select a level,",
		fonts.default,
		worldCanvas:getWidth() / 2 - math.floor(fonts.default:getWidth("Arrow keys to select a level,") / 2),
		worldCanvas:getHeight() - 32
	)
	love.graphics.print(
		"Enter to start.",
		fonts.default,
		worldCanvas:getWidth() / 2 - math.floor(fonts.default:getWidth("Enter to start") / 2),
		worldCanvas:getHeight() - 16
	)

	for i = 1, numOfLevels do
		local x = 16 + (i - 1) % 6 * 32
		local y = 32 + math.floor((i - 1) / 6) * 32

		if savedGame.levelReached < i then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		love.graphics.draw(sprites.ui.levelIcon, x, y)

		if i == self.selected then
			love.graphics.setColor(0, 1, 1, 1)
			love.graphics.rectangle("fill", x + 1, y - 1, 16, 16) -- TODO: Player
		else
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.print(
				i,
				fonts.default,
				x + 8 - math.floor(fonts.default:getWidth(i) / 2),
				y + 8 - math.floor(fonts.default:getHeight() / 2)
			)
		end
	end

	-- test level select
	-- love.graphics.draw(sprites.ui.levelIcon, x, y)
end

return levelSelectScene
