# Camera API

## Overview

The Camera system provides viewport management with smooth following, shake effects, and offset calculations. It's used to control what portion of the game world is visible on screen.

## Class: `camera`

### Constructor

#### `camera:new()`

Creates a new camera instance.

**Returns:**

- `camera` - New camera object

**Example:**

```lua
local Camera = require("src.core.camera")
local cam = Camera()
```

### Properties

- `x` (number): Current camera X position
- `y` (number): Current camera Y position
- `targetX` (number): Target X position to follow
- `targetY` (number): Target Y position to follow
- `shakeIntensity` (number): Current shake intensity
- `shakeDuration` (number): Remaining shake duration
- `shakeTimer` (number): Shake timer countdown
- `shakeX` (number): Current X shake offset
- `shakeY` (number): Current Y shake offset

### Methods

#### `camera:setTarget(x, y)`

Sets the target position for the camera to follow.

**Parameters:**

- `x` (number): Target X coordinate
- `y` (number): Target Y coordinate

**Example:**

```lua
cam:setTarget(player.x, player.y)
```

#### `camera:shake(intensity, duration)`

Triggers a camera shake effect.

**Parameters:**

- `intensity` (number, optional): Shake intensity (default: `Constants.CAMERA.SHAKE_INTENSITY`)
- `duration` (number, optional): Shake duration in seconds (default: `Constants.CAMERA.SHAKE_DURATION`)

**Example:**

```lua
-- Default shake
cam:shake()

-- Custom shake
cam:shake(10, 0.5)  -- Intense shake for 0.5 seconds
```

#### `camera:update(dt)`

Updates camera position and shake effects. Should be called every frame.

**Parameters:**

- `dt` (number): Delta time (time since last frame)

**Example:**

```lua
function gameScene:update(dt)
    cam:update(dt)
end
```

#### `camera:getOffset()`

Gets the current camera offset including shake effects.

**Returns:**

- `offsetX` (number): X offset including shake
- `offsetY` (number): Y offset including shake

**Example:**

```lua
local offsetX, offsetY = cam:getOffset()
```

#### `camera:apply()`

Applies the camera transform to the graphics context. Translates the drawing context by the camera offset.

**Example:**

```lua
function gameScene:draw()
    cam:apply()
    -- Draw game objects here
    cam:unapply()
end
```

#### `camera:unapply()`

Removes the camera transform from the graphics context. Resets the transformation matrix.

**Example:**

```lua
cam:unapply()  -- Reset transform after drawing
```

## Usage Patterns

### Following a Player

```lua
function gameScene:update(dt)
    -- Update camera target to follow player
    cam:setTarget(player.x + player.width / 2, player.y + player.height / 2)
    cam:update(dt)
end

function gameScene:draw()
    cam:apply()
    -- Draw world objects
    cam:unapply()
    -- Draw UI (not affected by camera)
end
```

### Camera Shake on Events

```lua
-- On player death
function player:die()
    gameScene.camera:shake(
        Constants.CAMERA.DEATH_SHAKE_INTENSITY,
        Constants.CAMERA.DEATH_SHAKE_DURATION
    )
end

-- On impact
function player:takeDamage()
    gameScene.camera:shake(5, 0.2)
end
```

### Smooth Camera Following

The current implementation uses instant following. For smooth following, you can enhance the `update` method:

```lua
function camera:update(dt)
    -- Smooth following with lerp
    local lerpSpeed = 5.0
    self.x = self.x + (self.targetX - self.x) * lerpSpeed * dt
    self.y = self.y + (self.targetY - self.y) * lerpSpeed * dt

    -- Update shake (existing code)
    -- ...
end
```

## Related Documentation

- [Camera Guide](../guides/camera-guide.md)
- [Constants API](./constants.md)
- [Game State](../states/game.md)
