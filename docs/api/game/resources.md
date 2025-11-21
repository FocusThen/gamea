# Resources API

## Overview

The Resources module loads all game assets including sprites, fonts, sounds, and music. It provides safe loading with error handling and a `playSound()` helper function.

## Global Variables

### `sprites`

Dictionary of sprite images:

```lua
sprites = {
    wipeImage1 = Image,        -- Wipe transition sprite 1
    wipeImage2 = Image,        -- Wipe transition sprite 2
    ui = {
        title = Image,         -- Title screen image
        levelSelect = Image,   -- Level select background
        levelIcon = Image,     -- Level icon
    },
    particles = {
        jump = Image,          -- Jump smoke sprite
        landing = Image,       -- Landing smoke sprite
        smoke = Image,         -- Dash smoke sprite
        walking = Image,       -- Walking effect sprite
        boxlanding = Image,    -- Box landing sprite
    },
}
```

### `fonts`

Dictionary of fonts:

```lua
fonts = {
    default = Font,  -- Default game font (VT323, 16px)
}
```

### `sounds`

Dictionary of sound effects:

```lua
sounds = {
    coin = { sound = Source, volume = 1 },
    dead = { sound = Source, volume = 1 },
    ground = { sound = Source, volume = 0.66 },
    ground2 = { sound = Source, volume = 0.4 },
    jump = { sound = Source, volume = 1 },
    pickup = { sound = Source, volume = 1 },
    select = { sound = Source, volume = 1 },
    takeout = { sound = Source, volume = 1 },
    foot1 = { sound = Source, volume = 1 },
    foot2 = { sound = Source, volume = 1 },
    spring = { sound = Source, volume = 0.66 },
}
```

### `music`

Dictionary of music tracks:

```lua
music = {
    game = Source,      -- Game music (looping)
    gameIntro = Source, -- Game intro music
}
```

## Functions

### `playSound(sfx)`

Plays a sound effect with volume settings applied.

**Parameters:**
- `sfx` (table): Sound object with `sound` and `volume` properties

**Behavior:**
- Stops sound if already playing
- Applies volume: `sfx.volume * gameSettings.sfxVol * gameSettings.masterVol`
- Plays sound

**Example:**
```lua
playSound(sounds.coin)
playSound(sounds.jump)
playSound(sounds.dead)
```

## Asset Loading

### Safe Loading

All assets use safe loading with `pcall`:
- Errors are caught and displayed
- Missing assets cause errors (intentional)

### Image Loading

```lua
local function loadImage(path)
    local success, image = pcall(love.graphics.newImage, path)
    if not success then
        error("Failed to load image: " .. path)
    end
    return image
end
```

### Font Loading

```lua
local function loadFont(path, size)
    local success, font = pcall(love.graphics.newFont, path, size)
    if not success then
        error("Failed to load font: " .. path)
    end
    return font
end
```

### Sound Loading

```lua
local function loadSound(path, type)
    local success, sound = pcall(love.audio.newSource, path, type)
    if not success then
        error("Failed to load sound: " .. path)
    end
    return sound
end
```

## Asset Paths

### Sprites

- `assets/sprites/wipe.png`
- `assets/sprites/wipe2.png`
- `assets/sprites/title.png`
- `assets/sprites/levelSelectBG.png`
- `assets/sprites/levelIcon.png`
- `assets/sprites/jumpsmoke.png`
- `assets/sprites/landingsmoke.png`
- `assets/sprites/smoke.png`
- `assets/sprites/walkeffect.png`
- `assets/sprites/boxlandingsmoke.png`

### Fonts

- `assets/fonts/vt323/VT323-Regular.ttf`

### Sounds

- `assets/sounds/coin.wav`
- `assets/sounds/dies.wav`
- `assets/sounds/ground.wav`
- `assets/sounds/jump.wav`
- `assets/sounds/pickup2.wav`
- `assets/sounds/select.wav`
- `assets/sounds/takeout2.wav`
- `assets/sounds/foot1.wav`
- `assets/sounds/foot2.wav`
- `assets/sounds/spring.wav`

### Music

- `assets/music/game.wav`
- `assets/music/gameIntro.wav`

## Usage Examples

### Playing Sounds

```lua
-- On coin pickup
function coin:onPickup()
    playSound(sounds.coin)
end

-- On player jump
function player:doJump()
    playSound(sounds.jump)
end

-- On player death
function player:kill()
    playSound(sounds.dead)
end
```

### Using Sprites

```lua
-- Draw title
love.graphics.draw(sprites.ui.title, x, y)

-- Draw particle effect
love.graphics.draw(sprites.particles.jump, x, y)
```

### Using Fonts

```lua
love.graphics.setFont(fonts.default)
love.graphics.print("Hello", x, y)
```

## Related Documentation

- [Particles System](../systems/particles.md)
- [Scene Effects](../systems/sceneEffects.md)
- [Game Settings](../../architecture/project-structure.md)

