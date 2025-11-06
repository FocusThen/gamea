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

-- Saw Constants
Constants.SAW = {
	WIDTH = 16,
	HEIGHT = 16,
	DEFAULT_SPEED = 50,
	DEFAULT_DISTANCE = 100,
}

-- Teleporter Constants
Constants.TELEPORTER = {
	WIDTH = 16,
	HEIGHT = 16,
	COOLDOWN = 0.5,
	TRANSITION_DURATION = 0.3,
}

-- Trigger Constants
Constants.TRIGGER = {
	ACTION_TYPES = {
		MOVE = "move",
		WAIT = "wait",
		ACTIVATE = "activate",
		SEQUENCE = "sequence",
		CUTSCENE = "cutscene",
		TIMER = "timer",
	},
	DEFAULT_DELAY = 0,
	DEFAULT_DURATION = 0.5,
}

-- Shader Constants
Constants.SHADERS = {
	CRT_INTENSITY = 1.0,
	BLOOM_INTENSITY = 1.0,
	SCANLINE_FREQUENCY = 600.0,
	CHROMA_OFFSET = 0.002,
}

-- Menu Constants
Constants.MENU = {
	BUTTON_SPACING = 20,
	MENU_Y_OFFSET = 56,
	SETTINGS_Y_OFFSET = 48,
	SETTINGS_ROW_SPACING = 24,
	SETTINGS_BAR_LEFT_RATIO = 1 / 6,
	SETTINGS_BAR_WIDTH_RATIO = 1 / 2,
	SETTINGS_BAR_WIDTH_EXTRA = 46,
	SETTINGS_CONTROLS_RIGHT_OFFSET = 40,
	SETTINGS_BUTTON_WIDTH = 12,
	SETTINGS_BUTTON_HEIGHT = 16,
	SETTINGS_BUTTON_PADDING = 2,
	BACK_BUTTON_Y_OFFSET = 32,
	SHADER_Y_OFFSET_AFTER_VOLUME = 3, -- Number of volume rows before shader toggle
}

-- Camera Constants
Constants.CAMERA = {
	SHAKE_INTENSITY = 5,
	SHAKE_DURATION = 0.3,
	DEATH_SHAKE_INTENSITY = 10,
	DEATH_SHAKE_DURATION = 0.5,
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

