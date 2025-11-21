# Camera Guide

## Overview

The camera system provides viewport management with smooth following and shake effects.

## Basic Usage

### Following the Player

```lua
function gameScene:update(dt)
    -- Update camera to follow player
    local centerX = player.x + player.width / 2
    local centerY = player.y + player.height / 2
    camera:setTarget(centerX, centerY)
    camera:update(dt)
end

function gameScene:draw()
    camera:apply()
    -- Draw game objects
    camera:unapply()
    -- Draw UI (not affected by camera)
end
```

## Camera Shake

### Basic Shake

```lua
camera:shake()  -- Default shake
```

### Custom Shake

```lua
camera:shake(10, 0.5)  -- Intensity 10, duration 0.5 seconds
```

### On Player Death

```lua
function player:kill()
    camera:shake(
        Constants.CAMERA.DEATH_SHAKE_INTENSITY,
        Constants.CAMERA.DEATH_SHAKE_DURATION
    )
end
```

## Smooth Following

The default camera follows instantly. For smooth following:

```lua
function camera:update(dt)
    -- Smooth following with lerp
    local lerpSpeed = 5.0
    self.x = self.x + (self.targetX - self.x) * lerpSpeed * dt
    self.y = self.y + (self.targetY - self.y) * lerpSpeed * dt
    
    -- Update shake
    -- ...
end
```

## Related Documentation

- [Camera API](../api/core/camera.md)
- [Camera Examples](../../examples/camera/)

