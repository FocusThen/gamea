# Load Map API

## Overview

The Load Map system loads game levels from Tiled map files (exported as Lua). It creates all game objects, links triggers to targets, and sets up the physics world.

## Function: `loadLevel(path)`

Loads a level from a Tiled map file.

**Parameters:**
- `path` (string): Level name without extension (e.g., `"level_1"`)

**Returns:**
- `map` (table): Map object with entities and tiled data

**Example:**
```lua
local loadLevel = require("src.game.loadMap")
local map = loadLevel("level_1")
```

## Map Structure

The returned map object contains:

```lua
map = {
    path = "level_1",           -- Level path
    tiled = tiledObject,        -- STI map object
    entities = {
        platforms = {},         -- Platform objects
        coins = {},            -- Coin objects
        boxes = {},            -- Box objects
        door = {},             -- Door object (single)
        player = player,       -- Player object
        triggers = {},         -- Trigger objects
        saws = {},             -- Saw objects
        teleporters = {},      -- Teleporter objects
        deadlyObjects = {},    -- Spike and deadly objects
    },
    entitiesById = {},         -- Lookup table by object ID
    bgColor = color,           -- Background color (if set in Tiled)
}
```

## Object Loading

### Platforms

Loaded from `"Platforms"` layer:
- Collision-only objects
- Added to physics world
- Drawn with map color shader

### Player

Loaded from `"Spawns"` layer with name `"player"`:
- Supports `doubleJump` and `dash` properties
- Single player per level

### Coins

Loaded from `"Spawns"` layer with name `"coin"`:
- Collectible pickups
- Removed on collection

### Boxes

Loaded from `"Spawns"` layer with name `"box"`:
- Pushable physics objects
- Affected by gravity

### Door

Loaded from `"Spawns"` layer with name `"door"`:
- Level exit
- Single door per level
- Stores current level name

### Triggers

Loaded from `"Spawns"` layer with name `"trigger"`:
- Linked to targets via `targetId`
- Supports all trigger actions

### Saws

Loaded from `"Dangers"` layer with name `"saw"`:
- Moving hazards
- Supports `direction`, `distance`, `speed` properties

### Teleporters

Loaded from `"Spawns"` layer with name `"teleporter"`:
- Linked in pairs via `targetId`
- Supports cooldown and transition settings

### Deadly Objects

Loaded from `"Dangers"` layer:
- `spike` - Visible spikes
- `deadlyObject` - Invisible hazards

## Entity Linking

Objects are linked via `entitiesById` table:
- Each object gets `_id` property from Tiled
- Triggers use `targetId` to find targets
- Teleporters are linked automatically

## Background Color

If Tiled map has `bgColor` property:
- Parsed from hex string
- Stored in `map.bgColor` as RGBA table
- Used for clearing canvas

## Usage Example

```lua
-- In game state
function gameScene:enter(enterparams)
    self.map = enterparams.map or loadLevel("level_1")
    self.player = self.map.entities.player
end

-- In door interaction
function door:interact()
    local nextLevel = "level_" .. (currentLevel + 1)
    stateMachine:setState("game", { map = loadLevel(nextLevel) })
end
```

## Related Documentation

- [Tiled Integration Guide](../../guides/tiled-integration.md)
- [Trigger API](../objects/trigger.md)
- [Game State](../states/game.md)
- [STI Library](https://github.com/karai17/Simple-Tiled-Implementation)

