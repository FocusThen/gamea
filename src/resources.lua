love.graphics.setDefaultFilter("nearest", "nearest")

sprites = {
	wipeImage1 = love.graphics.newImage("assets/sprites/wipe.png"),
	wipeImage2 = love.graphics.newImage("assets/sprites/wipe2.png"),
}

sprites.ui = {}
sprites.ui.title = love.graphics.newImage("assets/sprites/title.png")
sprites.ui.levelSelect = love.graphics.newImage("assets/sprites/levelSelectBG.png")
sprites.ui.levelIcon = love.graphics.newImage("assets/sprites/levelIcon.png")

sprites.particles = {}
sprites.particles.jump = love.graphics.newImage("assets/sprites/jumpsmoke.png")
sprites.particles.landing = love.graphics.newImage("assets/sprites/landingsmoke.png")
sprites.particles.smoke = love.graphics.newImage("assets/sprites/smoke.png")
sprites.particles.walking = love.graphics.newImage("assets/sprites/walkeffect.png")
sprites.particles.boxlanding = love.graphics.newImage("assets/sprites/boxlandingsmoke.png")

fonts = {}
fonts.default = love.graphics.newFont("assets/fonts/vt323/VT323-Regular.ttf", 16)

sounds = {}
sounds.coin = { sound = love.audio.newSource("assets/sounds/coin.wav", "static"), volume = 1 }
sounds.dead = { sound = love.audio.newSource("assets/sounds/dies.wav", "static"), volume = 1 }
sounds.ground = { sound = love.audio.newSource("assets/sounds/ground.wav", "static"), volume = 0.66 }
sounds.ground2 = { sound = love.audio.newSource("assets/sounds/ground.wav", "static"), volume = 0.4 }
sounds.jump = { sound = love.audio.newSource("assets/sounds/jump.wav", "static"), volume = 1 }
sounds.pickup = { sound = love.audio.newSource("assets/sounds/pickup2.wav", "static"), volume = 1 }
sounds.select = { sound = love.audio.newSource("assets/sounds/select.wav", "static"), volume = 1 }
sounds.takeout = { sound = love.audio.newSource("assets/sounds/takeout2.wav", "static"), volume = 1 }
sounds.foot1 = { sound = love.audio.newSource("assets/sounds/foot1.wav", "static"), volume = 1 }
sounds.foot2 = { sound = love.audio.newSource("assets/sounds/foot2.wav", "static"), volume = 1 }
sounds.spring = { sound = love.audio.newSource("assets/sounds/spring.wav", "static"), volume = 0.66 }

music = {}
music.game = love.audio.newSource("assets/music/game.wav", "stream")
music.game:setLooping(true)
music.gameIntro = love.audio.newSource("assets/music/gameIntro.wav", "stream")

function playSound(sfx)
	if sfx.sound:isPlaying() then
		sfx.sound:stop()
	end

	sfx.sound:setVolume(sfx.volume * gameSettings.sfxVol * gameSettings.masterVol)

	sfx.sound:play()
end
