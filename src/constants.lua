-- Game Constants
local Constants = {}

-- Physics Constants
Constants.PHYSICS = {
	CELL_SIZE = 16,
	GRAVITY = 800,
	PLAYER_SPEED = 60,
	PLAYER_JUMP = -250,
	PLAYER_DASH = 600,
	COYOTE_TIME = 0.1,
	FRICTION = 4000,
}

-- Player Constants
Constants.PLAYER = {
	WIDTH = 5,
	HEIGHT = 14,
	DRAW_OFFSET_X_RIGHT = -5.5,
	DRAW_OFFSET_X_LEFT = -3.5,
	DRAW_OFFSET_Y = -3,
}

-- Box Constants
Constants.BOX = {
	WIDTH = 16,
	HEIGHT = 16,
	GRAVITY = 800,
	FRICTION = 665,
	FRICTION_AIR = 33.25, -- friction / 20
}

-- Coin Constants
Constants.COIN = {
	WIDTH = 8,
	HEIGHT = 8,
}

-- Door Constants
Constants.DOOR = {
	WIDTH = 16,
	HEIGHT = 16,
}

-- Game Settings
Constants.GAME = {
	WIDTH = 320,
	HEIGHT = 192,
	DEFAULT_MASTER_VOL = 1,
	DEFAULT_MUSIC_VOL = 0.7,
	DEFAULT_SFX_VOL = 0.5,
}

-- Effects Constants
Constants.EFFECTS = {
	WIPE_DURATION = 1,
	FADE_DURATION = 3,
	FOOT_STEP_INTERVAL = 0.4,
	JUMP_EFFECT_DELAY = 0.1,
}

-- Velocity Thresholds
Constants.VELOCITY = {
	MIN_DASH = 50,
	SPRING_BOUNCE_MIN = 150,
	BOX_SPRING_BOUNCE_MIN = 50,
	LANDING_SOUND_THRESHOLD = 100,
	BOX_X_VEL_THRESHOLD = 22,
	BOX_X_VEL_MIN = 10,
	SLIP_CHECK_DISTANCE = 10,
}

return Constants

