# Main API

## Overview

The `main.lua` file is the entry point for the Love2D game. It initializes all systems, sets up the game loop, and handles window events.

## Global Variables

### `screen_scale`

Global screen scale factor for rendering.

### `offsetX`, `offsetY`

Global screen offset for centering.

### `gameSettings`

Global game settings table:

```lua
gameSettings = {
    masterVol = 1.0,
    musicVol = 0.7,
    sfxVol = 0.5,
    gameWidth = 320,
    gameHeight = 192,
}
```

### `savedGame`

Global saved game state:

```lua
savedGame = {
    settings = gameSettings,
    levelReached = 1,
}
```

## Love2D Callbacks

### `love.load()`

Initializes the game. Called once at startup.

**Initialization:**
1. Creates world canvas
2. Initializes physics world (Bump)
3. Initializes game systems (state machine, particles, shaders, etc.)
4. Loads saved game
5. Updates screen scale
6. Sets initial state

### `love.update(dt)`

Updates game state. Called every frame.

**Fixed Timestep:**
- Uses fixed timestep (1/60 seconds)
- Accumulates real delta time
- Runs multiple fixed updates if needed
- Caps accumulator to prevent spiral of death

### `love.draw()`

Draws the game. Called every frame.

**Rendering Pipeline:**
1. Draw to world canvas
2. Apply scene effects
3. Draw debug info (if enabled)
4. Apply shaders to canvas
5. Draw scaled canvas to screen

### `love.keypressed(key)`

Handles key press events.

**Debug Controls (dev mode):**
- `Ctrl+R` - Restart game
- `Ctrl+Q` - Quit game
- `Ctrl+D` - Toggle debug mode

### `love.keyreleased(key)`

Handles key release events. Forwards to state machine.

### `love.resize(width, height)`

Handles window resize. Updates screen scale and offsets.

## Helper Functions

### `updateScale()`

Updates screen scale and centering offsets based on window size.

**Calculations:**
- Calculates scale to fit game size in window
- Floors scale to integer
- Calculates centering offsets

## Fixed Timestep System

The game uses a fixed timestep for consistent physics:

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

## Related Documentation

- [State Machine API](./states/stateMachine.md)
- [Configuration](./conf.md)
- [Game Loop](../../architecture/game-loop.md)

