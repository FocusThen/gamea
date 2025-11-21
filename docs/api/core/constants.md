# Constants API

## Overview

The Constants module provides centralized configuration values for physics, game objects, UI, and effects. All constants are organized into logical groups for easy access and modification.

## Module: `Constants`

### Physics Constants

```lua
Constants.PHYSICS = {
    CELL_SIZE = 16,        -- Bump physics cell size
    GRAVITY = 800,         -- Global gravity value
    PLAYER_SPEED = 60,     -- Player horizontal speed
    PLAYER_JUMP = -200,    -- Player jump velocity
    PLAYER_DASH = 600,     -- Player dash speed
    COYOTE_TIME = 0.1,    -- Coyote time window (seconds)
    FRICTION = 4000,       -- Ground friction
}
```

### Player Constants

```lua
Constants.PLAYER = {
    WIDTH = 5,                    -- Player collision width
    HEIGHT = 14,                   -- Player collision height
    DRAW_OFFSET_X_RIGHT = -5.5,   -- Sprite X offset (facing right)
    DRAW_OFFSET_X_LEFT = -3.5,    -- Sprite X offset (facing left)
    DRAW_OFFSET_Y = -3,           -- Sprite Y offset
}
```

### Box Constants

```lua
Constants.BOX = {
    WIDTH = 16,           -- Box width
    HEIGHT = 16,          -- Box height
    GRAVITY = 800,        -- Box gravity
    FRICTION = 665,       -- Ground friction
    FRICTION_AIR = 33.25, -- Air friction (friction / 20)
}
```

### Coin Constants

```lua
Constants.COIN = {
    WIDTH = 8,   -- Coin width
    HEIGHT = 8,  -- Coin height
}
```

### Door Constants

```lua
Constants.DOOR = {
    WIDTH = 16,   -- Door width
    HEIGHT = 16, -- Door height
}
```

### Saw Constants

```lua
Constants.SAW = {
    WIDTH = 16,            -- Saw width
    HEIGHT = 16,           -- Saw height
    DEFAULT_SPEED = 50,    -- Default movement speed
    DEFAULT_DISTANCE = 100, -- Default movement distance
}
```

### Teleporter Constants

```lua
Constants.TELEPORTER = {
    WIDTH = 16,              -- Teleporter width
    HEIGHT = 16,            -- Teleporter height
    COOLDOWN = 0.5,         -- Cooldown between teleports (seconds)
    TRANSITION_DURATION = 0.3, -- Fade transition duration (seconds)
}
```

### Trigger Constants

```lua
Constants.TRIGGER = {
    ACTION_TYPES = {
        MOVE = "move",
        WAIT = "wait",
        ACTIVATE = "activate",
        SEQUENCE = "sequence",
        CUTSCENE = "cutscene",
        TIMER = "timer",
    },
    DEFAULT_DELAY = 0,      -- Default trigger delay
    DEFAULT_DURATION = 0.5, -- Default action duration
}
```

### Shader Constants

```lua
Constants.SHADERS = {
    CRT_INTENSITY = 1.0,        -- CRT shader intensity
    BLOOM_INTENSITY = 1.0,     -- Bloom shader intensity
    SCANLINE_FREQUENCY = 600.0, -- Scanline frequency
    CHROMA_OFFSET = 0.002,     -- Chromatic aberration offset
}
```

### Menu Constants

```lua
Constants.MENU = {
    BUTTON_SPACING = 20,                    -- Spacing between menu buttons
    MENU_Y_OFFSET = 56,                     -- Menu Y offset
    SETTINGS_Y_OFFSET = 48,                 -- Settings screen Y offset
    SETTINGS_ROW_SPACING = 24,              -- Settings row spacing
    SETTINGS_BAR_LEFT_RATIO = 1 / 6,        -- Settings bar left position ratio
    SETTINGS_BAR_WIDTH_RATIO = 1 / 2,       -- Settings bar width ratio
    SETTINGS_BAR_WIDTH_EXTRA = 46,          -- Extra width for settings bar
    SETTINGS_CONTROLS_RIGHT_OFFSET = 40,    -- Controls right offset
    SETTINGS_BUTTON_WIDTH = 12,             -- Settings button width
    SETTINGS_BUTTON_HEIGHT = 16,           -- Settings button height
    SETTINGS_BUTTON_PADDING = 2,           -- Settings button padding
    BACK_BUTTON_Y_OFFSET = 32,             -- Back button Y offset
    SHADER_Y_OFFSET_AFTER_VOLUME = 3,      -- Shader toggle Y offset after volume rows
}
```

### Camera Constants

```lua
Constants.CAMERA = {
    SHAKE_INTENSITY = 5,           -- Default shake intensity
    SHAKE_DURATION = 0.3,          -- Default shake duration
    DEATH_SHAKE_INTENSITY = 10,    -- Death shake intensity
    DEATH_SHAKE_DURATION = 0.5,    -- Death shake duration
}
```

### Game Constants

```lua
Constants.GAME = {
    WIDTH = 320,                -- Game viewport width
    HEIGHT = 192,              -- Game viewport height
    DEFAULT_MASTER_VOL = 1,    -- Default master volume (0-1)
    DEFAULT_MUSIC_VOL = 0.7,   -- Default music volume (0-1)
    DEFAULT_SFX_VOL = 0.5,     -- Default SFX volume (0-1)
}
```

### Effects Constants

```lua
Constants.EFFECTS = {
    WIPE_DURATION = 1,              -- Wipe transition duration
    FADE_DURATION = 3,              -- Fade transition duration
    FOOT_STEP_INTERVAL = 0.4,       -- Footstep sound interval
    JUMP_EFFECT_DELAY = 0.1,        -- Jump effect delay
}
```

### Velocity Thresholds

```lua
Constants.VELOCITY = {
    MIN_DASH = 50,                  -- Minimum dash velocity
    SPRING_BOUNCE_MIN = 150,        -- Minimum spring bounce velocity
    BOX_SPRING_BOUNCE_MIN = 50,     -- Minimum box spring bounce velocity
    LANDING_SOUND_THRESHOLD = 100,  -- Landing sound velocity threshold
    BOX_X_VEL_THRESHOLD = 22,       -- Box X velocity threshold
    BOX_X_VEL_MIN = 10,             -- Box X velocity minimum
    SLIP_CHECK_DISTANCE = 10,       -- Slip check distance
}
```

## Usage

### Accessing Constants

```lua
local Constants = require("src.core.constants")

-- Use in physics calculations
local gravity = Constants.PHYSICS.GRAVITY

-- Use in player code
local playerSpeed = Constants.PHYSICS.PLAYER_SPEED

-- Use in camera shake
cam:shake(
    Constants.CAMERA.DEATH_SHAKE_INTENSITY,
    Constants.CAMERA.DEATH_SHAKE_DURATION
)
```

### Modifying Constants

Constants can be modified to tweak game feel:

```lua
-- Make game faster
Constants.PHYSICS.PLAYER_SPEED = 80
Constants.PHYSICS.GRAVITY = 1000

-- Adjust camera shake
Constants.CAMERA.SHAKE_INTENSITY = 8
```

## Best Practices

1. **Centralized Configuration**: Keep all magic numbers in constants
2. **Grouped Organization**: Related constants are grouped together
3. **Descriptive Names**: Constant names clearly indicate their purpose
4. **Consistent Units**: All time values in seconds, speeds in pixels/second

## Related Documentation

- [Player API](../objects/player.md)
- [Camera API](./camera.md)
- [Physics System](../architecture/physics-system.md)

