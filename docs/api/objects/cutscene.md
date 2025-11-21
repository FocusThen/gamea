# Cutscene API

## Overview

The Cutscene object provides a system for creating scripted sequences with camera movement, text display, object movement, and trigger activation. Cutscenes are typically triggered by triggers or game events.

## Class: `cutscene`

### Constructor

#### `cutscene:new(props)`

Creates a new cutscene instance.

**Parameters:**
- `props` (table, optional): Cutscene configuration
  - `steps` (table): Array of cutscene step objects

**Example:**
```lua
local Cutscene = require("src.objects.cutscene")
local cutscene = Cutscene({
    steps = {
        { type = "wait", duration = 1.0 },
        { type = "showText", text = "Welcome!", duration = 3.0 },
        { type = "moveCamera", x = 200, y = 100, duration = 2.0 }
    }
})
```

### Properties

- `active` (boolean): Whether cutscene is currently playing
- `currentStep` (number): Current step index
- `steps` (table): Array of cutscene steps
- `player` (player|nil): Player reference
- `map` (map|nil): Map reference
- `cameraX`, `cameraY` (number): Current camera position
- `targetCameraX`, `targetCameraY` (number): Target camera position
- `cameraSpeed` (number): Camera movement speed (100 px/s)
- `currentText` (string|nil): Currently displayed text
- `textDuration` (number): Text display duration
- `textTimer` (number): Text display timer

### Methods

#### `cutscene:start(player, map)`

Starts the cutscene.

**Parameters:**
- `player` (player object): Player reference
- `map` (map object): Map reference

**Example:**
```lua
cutscene:start(player, map)
```

#### `cutscene:stop()`

Stops the cutscene and resets state.

#### `cutscene:update(dt)`

Updates cutscene state. Should be called every frame.

**Parameters:**
- `dt` (number): Delta time

#### `cutscene:draw()`

Draws cutscene elements (currently text display).

#### `cutscene:getCameraOffset()`

Gets the current camera offset for cutscene camera movement.

**Returns:**
- `offsetX` (number): X camera offset
- `offsetY` (number): Y camera offset

#### `cutscene:executeStep()`

Executes the current cutscene step. Called internally.

## Cutscene Steps

### Wait Step

Waits for a duration before continuing.

```lua
{
    type = "wait",
    duration = 1.0  -- Wait 1 second
}
```

### Move Camera Step

Moves the camera to a target position.

```lua
{
    type = "moveCamera",
    x = 200,        -- Target X
    y = 100,        -- Target Y
    duration = 2.0  -- Movement duration (or auto-calculated)
}
```

### Show Text Step

Displays text for a duration.

```lua
{
    type = "showText",
    text = "Hello World!",  -- Text to display
    duration = 3.0          -- Display duration
}
```

### Move Object Step

Moves a game object to a target position.

```lua
{
    type = "moveObject",
    targetId = 5,   -- Object ID to move
    x = 300,        -- Target X
    y = 200,        -- Target Y
    duration = 2.0  -- Movement duration
}
```

### Activate Trigger Step

Activates a trigger.

```lua
{
    type = "activateTrigger",
    targetId = 3,   -- Trigger ID to activate
    wait = 0.5      -- Wait time after activation
}
```

## Usage Example

### Creating a Cutscene

```lua
local Cutscene = require("src.objects.cutscene")

local introCutscene = Cutscene({
    steps = {
        -- Wait 1 second
        { type = "wait", duration = 1.0 },
        
        -- Show intro text
        { type = "showText", text = "Welcome to the game!", duration = 3.0 },
        
        -- Move camera to player
        { type = "moveCamera", x = player.x, y = player.y, duration = 2.0 },
        
        -- Move a box
        { type = "moveObject", targetId = boxId, x = 400, y = 200, duration = 1.5 },
        
        -- Activate a trigger
        { type = "activateTrigger", targetId = triggerId, wait = 0.5 },
        
        -- Wait and end
        { type = "wait", duration = 1.0 }
    }
})
```

### Triggering from Trigger

```lua
-- In trigger.lua
function trigger:doCutscene()
    if self.cutscene then
        local Cutscene = require("src.objects.cutscene")
        local cutsceneObj = Cutscene({ steps = self.cutscene })
        cutsceneObj:start(self.gameState.player, self.gameState.map)
    end
end
```

### Using in Game State

```lua
function gameScene:update(dt)
    if self.activeCutscene then
        self.activeCutscene:update(dt)
    end
end

function gameScene:draw()
    -- Apply cutscene camera offset if active
    if self.activeCutscene then
        local offsetX, offsetY = self.activeCutscene:getCameraOffset()
        love.graphics.translate(-offsetX, -offsetY)
    end
    
    -- Draw game
    
    -- Draw cutscene elements
    if self.activeCutscene then
        self.activeCutscene:draw()
    end
end
```

## Related Documentation

- [Trigger API](./trigger.md)
- [Camera API](../core/camera.md)
- [State Machine](../states/stateMachine.md)

