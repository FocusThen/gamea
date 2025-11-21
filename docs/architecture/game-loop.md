# Game Loop

## Overview

The game uses Love2D's callback system with a fixed timestep for consistent physics and smooth animations.

## Main Loop Flow

```
love.load()
    ↓
Initialize systems
    ↓
Load resources
    ↓
Set initial state
    ↓
┌─────────────────┐
│ love.update(dt) │ ← Fixed timestep (60 FPS)
│   ↓             │
│ Update state    │
│ Update entities │
│ Update systems  │
└─────────────────┘
    ↓
┌─────────────────┐
│ love.draw()     │
│   ↓             │
│ Draw to canvas  │
│ Apply shaders   │
│ Draw to screen  │
└─────────────────┘
```

## Fixed Timestep

The game uses a fixed timestep system for consistent physics:

```lua
local FIXED_DT = 1 / 60  -- 60 FPS
local accumulator = 0.0

function love.update(dt)
    accumulator = accumulator + dt
    
    -- Cap to prevent spiral of death
    if accumulator > 0.25 then
        accumulator = 0.25
    end
    
    -- Run fixed updates
    while accumulator >= FIXED_DT do
        flux.update(FIXED_DT)
        stateMachine:update(FIXED_DT)
        accumulator = accumulator - FIXED_DT
    end
end
```

## Update Order

1. Flux tweens (animations)
2. State machine (current state update)
3. State-specific updates (player, entities, etc.)

## Draw Order

1. Clear canvas
2. Apply camera
3. Draw background
4. Draw game objects
5. Draw particles
6. Remove camera
7. Apply shaders
8. Draw to screen

## Related Documentation

- [Main API](../api/main.md)
- [State Machine API](../api/states/stateMachine.md)

