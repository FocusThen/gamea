local LevelManager = Class:extend()

-- Level enum for easy reference
LevelManager.LEVELS = {
	TEST = "test_level",
}

-- Level progression order
LevelManager.LEVEL_ORDER = {
	TEST = "test_level",
}

function LevelManager:new()
	self.currentLevel = nil
	self.currentLevelName = nil
	self.currentLevelIndex = 0
	self.currentMap = nil -- STI map instance

	-- Level data storage
	self.levelData = {}

	-- Player spawn point
	self.playerSpawnX = 100
	self.playerSpawnY = 100
end

function LevelManager:loadLevel(levelName, useTransition)
	print("Loading level: " .. levelName)
	-- Clear existing entities
	EM:clear()

	local mapPath = "maps/" .. levelName .. ".lua"
	local success, map = pcall(Sti, mapPath)

	if not success then
		print("Error loading Tiled map: " .. mapPath)
		print("Error: " .. tostring(map))
		return false
	end

	self.currentMap = map
	self.currentLevelName = levelName

	-- Update level index if in progression
	for i, name in ipairs(self.LEVEL_ORDER) do
		if name == levelName then
			self.currentLevelIndex = i
			break
		end
	end

	self:buildLevel()

	return true
end

function LevelManager:buildLevel()
	if not self.currentMap then
		return
	end

	if self.currentMap.layers["Spawn"] then
		self.currentMap.layers["Spawn"].visible = false
	end
	if self.currentMap.layers["Entities"] then
		self.currentMap.layers["Entities"].visible = false
	end
	if self.currentMap.layers["Collision"] then
		self.currentMap.layers["Collision"].visible = false
	end

	self:parseMapLayers()

	local Player = require("src.entities.Player")
	local player = Player(self.playerSpawnX, self.playerSpawnY)
	EM:addEntity(player)

	_G.player = player
end

function LevelManager:parseMapLayers()
	-- Get spawn point from object layer
	local spawnLayer = self.currentMap.layers["Spawn"]
	if spawnLayer and spawnLayer.objects then
		for _, obj in ipairs(spawnLayer.objects) do
				self.playerSpawnX = obj.x
				self.playerSpawnY = obj.y
				break
		end
	end

	-- Create collision objects from object layer
	local collisionLayer = self.currentMap.layers["Collision"]
	if collisionLayer and collisionLayer.objects then
		local Ground = require("src.entities.Ground")

		for _, obj in ipairs(collisionLayer.objects) do
			local groundType = obj.type or "ground"
			EM:addEntity(Ground(obj.x, obj.y, obj.width, obj.height, groundType))
		end
	end

	-- Create entities from object layer
	local entityLayer = self.currentMap.layers["Entities"]
	if entityLayer and entityLayer.objects then
		for _, obj in ipairs(entityLayer.objects) do
			self:createEntityFromTiledObject(obj)
		end
	end
end

function LevelManager:createEntityFromTiledObject(obj)
	local entityType = obj.type or obj.name

	if entityType == "coin" then
		local Pickup = require("src.entities.Pickup")
		local pickupType = obj.properties and obj.properties.pickupType or "coin"
		local value = obj.properties and obj.properties.value or 10
		EM:addEntity(Pickup(obj.x, obj.y, pickupType, value))
	elseif entityType == "exit" then
		local LevelExit = require("src.entities.LevelExit")
		EM:addEntity(LevelExit(obj.x, obj.y))
	else
		print("Unknown entity type in Tiled: " .. entityType)
	end
end

function LevelManager:loadNextLevel(useTransition)
	if self.currentLevelIndex >= #self.LEVEL_ORDER then
		print("You've completed all levels!")
		-- Could trigger ending/credits here
		return false
	end

	local nextLevelName = self.LEVEL_ORDER[self.currentLevelIndex + 1]
	return self:loadLevel(nextLevelName, useTransition)
end

function LevelManager:loadPreviousLevel(useTransition)
	if self.currentLevelIndex <= 1 then
		print("Already at first level!")
		return false
	end

	local prevLevelName = self.LEVEL_ORDER[self.currentLevelIndex - 1]
	return self:loadLevel(prevLevelName, useTransition)
end

function LevelManager:reloadCurrentLevel(useTransition)
	if not self.currentLevelName then
		return false
	end

	return self:loadLevel(self.currentLevelName, useTransition)
end

function LevelManager:loadLevelByIndex(index, useTransition)
	if index < 1 or index > #self.LEVEL_ORDER then
		print("Invalid level index: " .. index)
		return false
	end

	local levelName = self.LEVEL_ORDER[index]
	return self:loadLevel(levelName, useTransition)
end

function LevelManager:getCurrentMap()
	return self.currentMap
end

function LevelManager:getCurrentLevelName()
	return self.currentLevelName or "none"
end

function LevelManager:getCurrentLevelIndex()
	return self.currentLevelIndex
end

function LevelManager:getTotalLevels()
	return #self.LEVEL_ORDER
end

function LevelManager:isLastLevel()
	return self.currentLevelIndex >= #self.LEVEL_ORDER
end

function LevelManager:isFirstLevel()
	return self.currentLevelIndex <= 1
end

-- Get level progress (for save/load system)
function LevelManager:getProgress()
	return {
		currentLevel = self.currentLevelName,
		levelIndex = self.currentLevelIndex,
		completedLevels = {},
	}
end

return LevelManager
