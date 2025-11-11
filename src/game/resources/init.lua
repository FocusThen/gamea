local ResourceManager = {}
ResourceManager.__index = ResourceManager

local function loadImage(path)
	local success, image = pcall(love.graphics.newImage, path)
	if not success then
		error("Failed to load image: " .. path .. "\n" .. image)
	end
	return image
end

local function tryLoadImage(path)
	local success, image = pcall(love.graphics.newImage, path)
	if success then
		return image
	end
	return nil
end

local function loadFont(path, size)
	local success, font = pcall(love.graphics.newFont, path, size)
	if not success then
		error("Failed to load font: " .. path .. "\n" .. font)
	end
	return font
end

local function loadSound(path, soundType)
	local success, sound = pcall(love.audio.newSource, path, soundType)
	if not success then
		error("Failed to load sound: " .. path .. "\n" .. sound)
	end
	return sound
end

local function loadSprites()
	local sprites = {
		wipeImage1 = loadImage("assets/sprites/wipe.png"),
		wipeImage2 = loadImage("assets/sprites/wipe2.png"),
		ui = {},
		particles = {},
	}

	sprites.ui.title = loadImage("assets/sprites/title.png")
	sprites.ui.levelSelect = tryLoadImage("assets/sprites/levelSelectBG.png")
	sprites.ui.levelIcon = tryLoadImage("assets/sprites/levelIcon.png")

	sprites.particles.jump = loadImage("assets/sprites/jumpsmoke.png")
	sprites.particles.landing = loadImage("assets/sprites/landingsmoke.png")
	sprites.particles.smoke = loadImage("assets/sprites/smoke.png")
	sprites.particles.walking = loadImage("assets/sprites/walkeffect.png")
	sprites.particles.boxlanding = loadImage("assets/sprites/boxlandingsmoke.png")

	return sprites
end

local function loadFonts()
	return {
		default = loadFont("assets/fonts/vt323/VT323-Regular.ttf", 16),
	}
end

local function loadSounds()
	return {
		coin = { sound = loadSound("assets/sounds/coin.wav", "static"), volume = 1 },
		dead = { sound = loadSound("assets/sounds/dies.wav", "static"), volume = 1 },
		ground = { sound = loadSound("assets/sounds/ground.wav", "static"), volume = 0.66 },
		ground2 = { sound = loadSound("assets/sounds/ground.wav", "static"), volume = 0.4 },
		jump = { sound = loadSound("assets/sounds/jump.wav", "static"), volume = 1 },
		pickup = { sound = loadSound("assets/sounds/pickup2.wav", "static"), volume = 1 },
		select = { sound = loadSound("assets/sounds/select.wav", "static"), volume = 1 },
		takeout = { sound = loadSound("assets/sounds/takeout2.wav", "static"), volume = 1 },
		foot1 = { sound = loadSound("assets/sounds/foot1.wav", "static"), volume = 1 },
		foot2 = { sound = loadSound("assets/sounds/foot2.wav", "static"), volume = 1 },
		spring = { sound = loadSound("assets/sounds/spring.wav", "static"), volume = 0.66 },
	}
end

local function loadMusic()
	local music = {
		game = loadSound("assets/music/game.wav", "stream"),
		gameIntro = loadSound("assets/music/gameIntro.wav", "stream"),
	}

	music.game:setLooping(true)

	return music
end

function ResourceManager.new()
	local self = setmetatable({}, ResourceManager)
	self.sprites = loadSprites()
	self.fonts = loadFonts()
	self.sounds = loadSounds()
	self.music = loadMusic()
	return self
end

function ResourceManager:playEntry(entry)
	if not entry or not entry.sound then
		return
	end

	if entry.sound:isPlaying() then
		entry.sound:stop()
	end

	local gameVol = (gameSettings and gameSettings.sfxVol) or 1
	local masterVol = (gameSettings and gameSettings.masterVol) or 1
	entry.sound:setVolume((entry.volume or 1) * gameVol * masterVol)
	entry.sound:play()
end

function ResourceManager:play(id)
	self:playEntry(self.sounds[id])
end

return ResourceManager

