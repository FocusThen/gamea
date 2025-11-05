local saveSystem = Object:extend()

local Constants = require("src.constants")

function saveSystem:new()
	self.saveFilePath = "savegame.dat"
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
	
	-- Serialize to JSON-like string (simple implementation)
	local saveString = self:serialize(saveData)
	
	-- Write to file
	local success, err = pcall(function()
		love.filesystem.write(self.saveFilePath, saveString)
	end)
	
	if not success then
		print("Error saving game: " .. tostring(err))
	end
end

function saveSystem:loadGame()
	if not self:hasSave() then
		return false
	end
	
	local success, content = pcall(function()
		return love.filesystem.read(self.saveFilePath)
	end)
	
	if not success or not content then
		return false
	end
	
	-- Deserialize
	local saveData = self:deserialize(content)
	
	if saveData then
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
	
	return false
end

function saveSystem:serialize(data)
	-- Use Lua's string.dump for tables (simple but works for our use case)
	-- For nested tables, we'll use a simple approach
	local function serializeValue(v)
		if type(v) == "number" then
			return tostring(v)
		elseif type(v) == "boolean" then
			return v and "true" or "false"
		elseif type(v) == "string" then
			return '"' .. v .. '"'
		elseif type(v) == "table" then
			local result = {}
			table.insert(result, "{")
			local first = true
			for k, val in pairs(v) do
				if not first then
					table.insert(result, ",")
				end
				first = false
				if type(k) == "string" then
					table.insert(result, k .. "=")
				else
					table.insert(result, "[" .. tostring(k) .. "]=")
				end
				table.insert(result, serializeValue(val))
			end
			table.insert(result, "}")
			return table.concat(result)
		end
		return "nil"
	end
	
	return "return " .. serializeValue(data)
end

function saveSystem:deserialize(str)
	-- Use load to execute the serialized string
	local func, err = load(str)
	if not func then
		return nil
	end
	
	local success, result = pcall(func)
	if success then
		return result
	end
	
	return nil
end

function saveSystem:deleteSave()
	if self:hasSave() then
		love.filesystem.remove(self.saveFilePath)
	end
end

return saveSystem

