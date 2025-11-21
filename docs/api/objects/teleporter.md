# Teleporter API

## Overview

The Teleporter object creates a teleportation system where players can move between two linked teleporters. Teleporters work in pairs and include cooldown and fade transition effects.

## Class: `teleporter`

### Constructor

#### `teleporter:new(x, y, props)`

Creates a new teleporter instance.

**Parameters:**
- `x` (number): X position
- `y` (number): Y position
- `props` (table, optional): Properties from Tiled map
  - `targetId` (number|object reference): ID of destination teleporter
  - `targetX` (number, optional): Alternative X destination coordinate
  - `targetY` (number, optional): Alternative Y destination coordinate
  - `cooldown` (number, optional): Cooldown between teleports (default: 0.5)
  - `transitionDuration` (number, optional): Fade transition duration (default: 0.3)
  - `width` (number, optional): Custom width
  - `height` (number, optional): Custom height

**Example:**
```lua
local Teleporter = require("src.objects.teleporter")
local teleporter = Teleporter(100, 200, {
    targetId = otherTeleporterId,
    cooldown = 1.0
})
```

### Properties

- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Collision dimensions (default: 16x16)
- `type` (string): Always `"teleporter"`
- `targetId` (number|nil): ID of target teleporter
- `targetX`, `targetY` (number|nil): Alternative destination coordinates
- `targetTeleporter` (teleporter|nil): Linked teleporter object (set by loadMap)
- `cooldown` (number): Cooldown time in seconds
- `transitionDuration` (number): Fade transition duration
- `lastTeleportTime` (number): Last teleport timestamp
- `teleporting` (boolean): Whether teleportation is in progress

### Methods

#### `teleporter:interact(player)`

Handles player interaction with the teleporter.

**Parameters:**
- `player` (player object): The player to teleport

**Behavior:**
1. Checks cooldown (prevents rapid teleportation)
2. Verifies not already teleporting
3. Determines destination (target teleporter or coordinates)
4. Starts fade transition
5. Teleports player to destination
6. Updates physics world
7. Resets teleporting flag after delay

**Example:**
```lua
-- Called automatically when player touches teleporter
teleporter:interact(player)
```

#### `teleporter:draw()`

Draws the teleporter as a cyan rectangle with a white center indicator.

## Teleporter Pairs

### Linking Teleporters

Teleporters are linked via `targetId`:
1. Create two teleporter objects in Tiled
2. Set `targetId` of first to second's ID
3. Set `targetId` of second to first's ID
4. `loadMap` automatically links them via `targetTeleporter`

### Alternative: Coordinate Destination

Instead of linking to another teleporter, you can specify coordinates:
```lua
teleporter = Teleporter(100, 200, {
    targetX = 500,
    targetY = 300
})
```

## Cooldown System

Prevents rapid teleportation:
- Default cooldown: 0.5 seconds
- Uses `love.timer.getTime()` for timing
- Both teleporters share cooldown state

## Transition Effects

Uses fade transition for smooth teleportation:
- Default duration: 0.3 seconds
- Fades out → teleports → fades in
- Provides visual feedback

## Usage Example

```lua
-- In loadMap.lua
local Teleporter = require("src.objects.teleporter")

-- Create teleporter pair
local teleporter1 = Teleporter(100, 200, { targetId = teleporter2Id })
local teleporter2 = Teleporter(500, 300, { targetId = teleporter1Id })

-- Link them (done automatically by loadMap)
teleporter1.targetTeleporter = teleporter2
teleporter2.targetTeleporter = teleporter1
```

## Related Documentation

- [Load Map API](../game/loadMap.md)
- [Scene Effects](../systems/sceneEffects.md)
- [Constants API](../core/constants.md)

