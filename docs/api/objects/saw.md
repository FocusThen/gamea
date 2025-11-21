# Saw API

## Overview

The Saw object represents a moving hazard that kills the player on contact. Saws move back and forth continuously in either horizontal or vertical directions.

## Class: `saw`

### Constructor

#### `saw:new(x, y, props)`

Creates a new saw instance.

**Parameters:**

- `x` (number): Initial X position
- `y` (number): Initial Y position
- `props` (table, optional): Properties from Tiled map
  - `direction` (string): `"horizontal"` or `"vertical"` (default: `"horizontal"`)
  - `distance` (number): Movement distance in pixels (default: 100)
  - `speed` (number): Movement speed in pixels/second (default: 50)
  - `width` (number, optional): Custom width
  - `height` (number, optional): Custom height

**Example:**

```lua
local Saw = require("src.objects.saw")

-- Horizontal moving saw
local saw = Saw(100, 200, {
    direction = "horizontal",
    distance = 150,
    speed = 60
})

-- Vertical moving saw
local saw = Saw(100, 200, {
    direction = "vertical",
    distance = 100,
    speed = 40
})
```

### Properties

- `x`, `y` (number): Current position coordinates
- `width`, `height` (number): Collision dimensions (default: 16x16)
- `type` (string): Always `"saw"`
- `direction` (string): Movement direction (`"horizontal"` or `"vertical"`)
- `distance` (number): Total movement distance
- `speed` (number): Movement speed in pixels/second
- `startX`, `startY` (number): Starting position
- `endX`, `endY` (number): Ending position
- `movingForward` (boolean): Movement direction flag
- `currentProgress` (number): Movement progress (0 to 1)

### Methods

#### `saw:update(dt)`

Updates saw position based on movement direction and speed.

**Parameters:**

- `dt` (number): Delta time

**Movement Logic:**

- Calculates movement based on direction
- Moves forward until reaching end, then reverses
- Uses linear interpolation (lerp) for smooth movement
- Updates physics world position

#### `saw:interact(player)`

Handles player collision. Kills the player.

**Parameters:**

- `player` (player object): The player object

**Example:**

```lua
-- Called automatically when player touches saw
saw:interact(player)  -- Kills player
```

#### `saw:draw()`

Draws the saw as a red filled rectangle with dark red outline.

## Movement System

### Horizontal Movement

```lua
saw = Saw(100, 200, {
    direction = "horizontal",
    distance = 150,  -- Moves 150 pixels right, then back
    speed = 60       -- 60 pixels per second
})
```

Movement range: `startX` to `startX + distance`

### Vertical Movement

```lua
saw = Saw(100, 200, {
    direction = "vertical",
    distance = 100,  -- Moves 100 pixels down, then back
    speed = 40       -- 40 pixels per second
})
```

Movement range: `startY` to `startY + distance`

### Movement Pattern

1. Starts at `startX/Y`
2. Moves toward `endX/Y` at `speed` pixels/second
3. When reaching end, reverses direction
4. Continues back and forth indefinitely

## Usage Example

```lua
-- In loadMap.lua
local Saw = require("src.objects.saw")

-- Create horizontal saw
local saw1 = Saw(100, 200, {
    direction = "horizontal",
    distance = 200,
    speed = 50
})

-- Create vertical saw
local saw2 = Saw(300, 100, {
    direction = "vertical",
    distance = 150,
    speed = 60
})

-- In game state
function gameScene:update(dt)
    for _, saw in ipairs(map.entities.saws) do
        saw:update(dt)
    end
end

function gameScene:draw()
    for _, saw in ipairs(map.entities.saws) do
        saw:draw()
    end
end
```

## Related Documentation

- [Constants API](../core/constants.md)
- [Player API](./player.md)
