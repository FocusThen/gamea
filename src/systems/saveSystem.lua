local saveSystem = Object:extend()

local json = require("lib.json.json")

function saveSystem:new()
	self.saveFilePath = "savegame.json"
end

function saveSystem:hasSave()
	if not self.saveFilePath then
		return false
	end
	return love.filesystem.getInfo(self.saveFilePath) ~= nil
end

function saveSystem:saveGame()
	-- Prepare save data
	local saveData = {
		levelReached = savedGame.levelReached,
		settings = {
			masterVol = gameSettings.masterVol,
			musicVol = gameSettings.musicVol,
			sfxVol = gameSettings.sfxVol,
			gameWidth = gameSettings.gameWidth,
			gameHeight = gameSettings.gameHeight,
		},
		shaderSettings = {
			crtEnabled = shaderSystem.enabled.crt,
		},
	}
	
	-- Convert to JSON string
	local jsonString = json.encode(saveData)
	
	-- Write to file
	local success, err = pcall(function()
		love.filesystem.write(self.saveFilePath, jsonString)
	end)
	
	if not success then
		print("Error saving game: " .. tostring(err))
	end
end

function saveSystem:loadGame()
	if not self:hasSave() then
		return false
	end
	
	local fileSuccess, content = pcall(function()
		return love.filesystem.read(self.saveFilePath)
	end)
	
	if not fileSuccess or not content then
		return false
	end
	
	-- Parse JSON (rxi's json library throws errors on failure)
	local parseSuccess, saveData = pcall(json.decode, content)
	
	if not parseSuccess then
		print("Error parsing save file: " .. tostring(saveData))
		return false
	end
	
	-- Restore game state
	if saveData.levelReached then
		savedGame.levelReached = saveData.levelReached
	end
	
	-- Restore settings
	if saveData.settings then
		if saveData.settings.masterVol then
			gameSettings.masterVol = saveData.settings.masterVol
		end
		if saveData.settings.musicVol then
			gameSettings.musicVol = saveData.settings.musicVol
		end
		if saveData.settings.sfxVol then
			gameSettings.sfxVol = saveData.settings.sfxVol
		end
	end
	
	-- Restore shader settings
	if saveData.shaderSettings and saveData.shaderSettings.crtEnabled ~= nil then
		shaderSystem:setEnabled("crt", saveData.shaderSettings.crtEnabled)
	end
	
	savedGame.settings = gameSettings
	return true
end


function saveSystem:deleteSave()
	if self:hasSave() then
		love.filesystem.remove(self.saveFilePath)
	end
end

return saveSystem

