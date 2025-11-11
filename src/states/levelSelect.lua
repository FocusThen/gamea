local levelSelectScene = Object:extend()

local inputConfig = require("src.systems.inputConfig")
local Colors = require("src.core.colors")
local uiUtils = require("src.ui.utils")
local Utils = require("src.core.utils")
local LevelLoader = require("src.game.level.loader")

local detectedLevels = Utils.countLevels()
_G.numOfLevels = math.max(detectedLevels, 1)

local GRID_COLUMNS = 6
local NAVIGATION_OFFSETS = {
	left = -1,
	right = 1,
	up = -GRID_COLUMNS,
	down = GRID_COLUMNS,
}

function levelSelectScene:playSelect()
	if resourceManager and resourceManager.play then
		resourceManager:play("select")
	else
		playSound(sounds.select)
	end
end

function levelSelectScene:clampSelection()
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

function levelSelectScene:adjustSelection(offset)
	self.selected = self.selected + offset
	self:playSelect()
	self:clampSelection()
end

function levelSelectScene:new()
	self.bindings = inputConfig.createMenuBindings()

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
					map = LevelLoader.load("level_" .. self.selected),
				})
			end)
	else
		for action, offset in pairs(NAVIGATION_OFFSETS) do
			if self.bindings:pressed(action) then
				self:adjustSelection(offset)
				break
			end
		end
	end

	self:clampSelection()
end

function levelSelectScene:draw()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.draw(sprites.ui.levelSelect, 0, 0)

	-- Draw title
	uiUtils.drawCenteredText("Level Select", fonts.default, 8, Colors.TEXT_DARK)

	-- Draw instructions
	uiUtils.drawCenteredText("Arrow keys to select a level,", fonts.default, worldCanvas:getHeight() - 32, Colors.TEXT_PRIMARY)
	uiUtils.drawCenteredText("Enter to start.", fonts.default, worldCanvas:getHeight() - 16, Colors.TEXT_PRIMARY)

	for i = 1, numOfLevels do
		local x = 16 + (i - 1) % 6 * 32
		local y = 32 + math.floor((i - 1) / 6) * 32

		if savedGame.levelReached < i then
			love.graphics.setColor(Colors.GREY)
		else
			love.graphics.setColor(Colors.WHITE)
		end

		love.graphics.draw(sprites.ui.levelIcon, x, y)

		if i == self.selected then
			love.graphics.setColor(Colors.SELECTION)
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

	love.graphics.setColor(1, 1, 1, 1)
end

return levelSelectScene
