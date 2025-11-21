# Particles System API

## Overview

The Particles system manages visual effects like jump smoke, landing effects, dash effects, and walking particles. It uses anim8 for sprite animations and provides a simple interface for creating effects.

## Class: `particles`

### Constructor

#### `particles:new()`

Creates a new particles system instance and loads all effect definitions.

**Example:**
```lua
local Particles = require("src.systems.particles")
particleEffects = Particles()
```

### Properties

- `effects` (table): Dictionary of effect templates
- `activeEffects` (table): Array of currently active effects

### Methods

#### `particles:update(dt)`

Updates all active particle effects. Removes effects that have finished playing.

**Parameters:**
- `dt` (number): Delta time

**Example:**
```lua
function gameScene:update(dt)
    particleEffects:update(dt)
end
```

#### `particles:draw()`

Draws all active particle effects.

**Example:**
```lua
function gameScene:draw()
    particleEffects:draw()
end
```

#### `particles:createEffect(effect, x, y, flip)`

Creates a new particle effect instance.

**Parameters:**
- `effect` (string): Effect name (`"jump"`, `"dash"`, `"landing"`, `"boxLanding"`, `"walk"`)
- `x` (number): X position
- `y` (number): Y position
- `flip` (boolean, optional): Whether to flip horizontally

**Example:**
```lua
-- Create jump effect
particleEffects:createEffect("jump", player.x, player.y)

-- Create walk effect flipped
particleEffects:createEffect("walk", player.x, player.y, true)
```

#### `particles:loadEffects()`

Loads all effect definitions. Called automatically during initialization.

**Available Effects:**
- `jump` - Jump smoke effect (7 frames, 0.075s per frame)
- `dash` - Dash smoke effect (6 frames, 0.1s per frame)
- `landing` - Landing smoke effect (4 frames, 0.075s per frame)
- `boxLanding` - Box landing effect (4 frames, 0.075s per frame)
- `walk` - Walking effect (6 frames, 0.1s per frame)

## Effect Details

### Jump Effect

- Sprite: `assets/sprites/jumpsmoke.png`
- Grid: 20x6 pixels per frame
- Frames: 1-7
- Speed: 0.075s per frame
- Status: `pauseAtEnd` (stops on last frame)

### Dash Effect

- Sprite: `assets/sprites/smoke.png`
- Grid: 16x10 pixels per frame
- Frames: 1-6
- Speed: 0.1s per frame
- Status: `pauseAtEnd`

### Landing Effect

- Sprite: `assets/sprites/landingsmoke.png`
- Grid: 16x4 pixels per frame
- Frames: 1-4
- Speed: 0.075s per frame
- Status: `pauseAtEnd`

### Box Landing Effect

- Sprite: `assets/sprites/boxlandingsmoke.png`
- Grid: 28x4 pixels per frame
- Frames: 1-4
- Speed: 0.075s per frame
- Status: `pauseAtEnd`

### Walk Effect

- Sprite: `assets/sprites/walkeffect.png`
- Grid: 10x3 pixels per frame
- Frames: 1-6
- Speed: 0.1s per frame
- Status: `pauseAtEnd`

## Usage Examples

### Player Jump Effect

```lua
function player:doJump()
    particleEffects:createEffect("jump", 
        self.x + self.width / 2 - 10, 
        self.y + self.height - 6
    )
    self.yVel = self.jump
end
```

### Player Dash Effect

```lua
function player:dash()
    local ex = self.facing and self.x - 16 or self.x + self.width
    particleEffects:createEffect("dash", ex, self.y + self.height - 10, not self.facing)
end
```

### Landing Effect

```lua
if player:checkGrounded() and justLanded then
    particleEffects:createEffect("landing", 
        player.x + player.width / 2 - 8, 
        player.y + player.height - 4
    )
end
```

### Walking Effect

```lua
if player:isMoving() then
    local x = player.facing and player.x - 9 or player.x + player.width - 1
    particleEffects:createEffect("walk", x, player.y + player.height - 3, not player.facing)
end
```

## Adding Custom Effects

To add a new effect:

1. Add sprite to `assets/sprites/`
2. Add effect definition in `loadEffects()`:

```lua
self.effects["myEffect"] = {}
self.effects["myEffect"].sheet = loadImage("assets/sprites/myEffect.png")
self.effects["myEffect"].sheet:setFilter("nearest", "nearest")
local grid = anim8.newGrid(frameWidth, frameHeight, 
    self.effects["myEffect"].sheet:getWidth(), 
    self.effects["myEffect"].sheet:getHeight())
self.effects["myEffect"].anim = anim8.newAnimation(
    grid("1-5", 1),  -- 5 frames
    0.1,             -- 0.1s per frame
    "pauseAtEnd"     -- Stop on last frame
)
```

3. Use it:

```lua
particleEffects:createEffect("myEffect", x, y)
```

## Related Documentation

- [Resources API](../game/resources.md)
- [Player API](../objects/player.md)
- [Anim8 Library](../../architecture/rendering-pipeline.md)

