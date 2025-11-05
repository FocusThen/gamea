love.graphics.setDefaultFilter("nearest", "nearest")

-- Helper function to safely load resources
local function loadImage(path)
	local success, image = pcall(love.graphics.newImage, path)
	if not success then
		error("Failed to load image: " .. path .. "\n" .. image)
	end
	return image
end

local function loadFont(path, size)
	local success, font = pcall(love.graphics.newFont, path, size)
	if not success then
		error("Failed to load font: " .. path .. "\n" .. font)
	end
	return font
end

local function loadSound(path, type)
	local success, sound = pcall(love.audio.newSource, path, type)
	if not success then
		error("Failed to load sound: " .. path .. "\n" .. sound)
	end
	return sound
end

-- Load sprites
sprites = {
	wipeImage1 = loadImage("assets/sprites/wipe.png"),
	wipeImage2 = loadImage("assets/sprites/wipe2.png"),
}

sprites.ui = {}
sprites.ui.title = loadImage("assets/sprites/title.png")
-- These may not exist, so we'll check for them
local success, levelSelect = pcall(love.graphics.newImage, "assets/sprites/levelSelectBG.png")
sprites.ui.levelSelect = success and levelSelect or nil

local success2, levelIcon = pcall(love.graphics.newImage, "assets/sprites/levelIcon.png")
sprites.ui.levelIcon = success2 and levelIcon or nil

sprites.particles = {}
sprites.particles.jump = loadImage("assets/sprites/jumpsmoke.png")
sprites.particles.landing = loadImage("assets/sprites/landingsmoke.png")
sprites.particles.smoke = loadImage("assets/sprites/smoke.png")
sprites.particles.walking = loadImage("assets/sprites/walkeffect.png")
sprites.particles.boxlanding = loadImage("assets/sprites/boxlandingsmoke.png")

-- Load fonts
fonts = {}
fonts.default = loadFont("assets/fonts/vt323/VT323-Regular.ttf", 16)

-- Load sounds
sounds = {}
sounds.coin = { sound = loadSound("assets/sounds/coin.wav", "static"), volume = 1 }
sounds.dead = { sound = loadSound("assets/sounds/dies.wav", "static"), volume = 1 }
sounds.ground = { sound = loadSound("assets/sounds/ground.wav", "static"), volume = 0.66 }
sounds.ground2 = { sound = loadSound("assets/sounds/ground.wav", "static"), volume = 0.4 }
sounds.jump = { sound = loadSound("assets/sounds/jump.wav", "static"), volume = 1 }
sounds.pickup = { sound = loadSound("assets/sounds/pickup2.wav", "static"), volume = 1 }
sounds.select = { sound = loadSound("assets/sounds/select.wav", "static"), volume = 1 }
sounds.takeout = { sound = loadSound("assets/sounds/takeout2.wav", "static"), volume = 1 }
sounds.foot1 = { sound = loadSound("assets/sounds/foot1.wav", "static"), volume = 1 }
sounds.foot2 = { sound = loadSound("assets/sounds/foot2.wav", "static"), volume = 1 }
sounds.spring = { sound = loadSound("assets/sounds/spring.wav", "static"), volume = 0.66 }

-- Load music
music = {}
music.game = loadSound("assets/music/game.wav", "stream")
music.game:setLooping(true)
music.gameIntro = loadSound("assets/music/gameIntro.wav", "stream")

function playSound(sfx)
	if sfx.sound:isPlaying() then
		sfx.sound:stop()
	end

	sfx.sound:setVolume(sfx.volume * gameSettings.sfxVol * gameSettings.masterVol)

	sfx.sound:play()
end
