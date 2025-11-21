# Door API

## Overview

The Door object represents a level exit. When the player touches a door, they advance to the next level or reach the ending if it's the last level.

## Class: `door`

### Constructor

#### `door:new(x, y, currentLevel)`

Creates a new door instance.

**Parameters:**
- `x` (number): X position
- `y` (number): Y position
- `currentLevel` (string): Current level name (e.g., `"level_1"`)

**Example:**
```lua
local Door = require("src.objects.door")
local door = Door(300, 100, "level_1")
```

### Properties

- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Collision dimensions (16x16)
- `type` (string): Always `"door"`
- `currentLevel` (string): Current level identifier

### Methods

#### `door:draw()`

Draws the door as a cyan filled rectangle.

#### `door:interact(player)`

Handles player interaction with the door. Transitions to next level or ending.

**Parameters:**
- `player` (player object): The player object (currently unused)

**Behavior:**
1. Extracts level number from `currentLevel`
2. Calculates next level name
3. If last level: saves game and goes to ending
4. Otherwise: saves game and loads next level
5. Uses wipe transition effect

**Example:**
```lua
-- Called automatically when player touches door
door:interact(player)
```

## Level Progression

### Level Naming Convention

Doors expect levels named `level_N.lua` where N is a number:
- `level_1` → next is `level_2`
- `level_2` → next is `level_3`
- etc.

### Transition Flow

```
Player touches door
    ↓
Extract level number
    ↓
Calculate next level
    ↓
Save game state
    ↓
Wipe transition effect
    ↓
Load next level OR go to ending
```

## Usage Example

```lua
-- In loadMap.lua
local Door = require("src.objects.door")
local door = Door(300, 100, "level_1")

-- Door interaction handled automatically by player collision
```

## Related Documentation

- [Save System](../systems/saveSystem.md)
- [Scene Effects](../systems/sceneEffects.md)
- [State Machine](../states/stateMachine.md)

