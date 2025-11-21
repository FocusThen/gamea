# Game State API

## Overview

The Game State is the main gameplay state where the player interacts with the level. It manages the player, entities, camera, and game logic.

## Class: `gameScene`

### Constructor

#### `gameScene:new()`

Creates a new game state instance.

**Initialization:**
- Sets up input bindings
- Initializes camera
- Sets death timer

### Methods

#### `gameScene:enter(enterparams)`

Called when entering the game state.

**Parameters:**
- `enterparams` (table): Parameters
  - `map` (table): Map object from `loadLevel()`

**Behavior:**
- Sets map and player
- Initializes camera
- Links triggers to game state for cutscenes

#### `gameScene:update(dt)`

Updates game state. Called every frame.

**Updates:**
- Player
- Particle effects
- Boxes
- Coins (removes deleted ones)
- Triggers
- Saws
- Camera
- Death/restart logic

#### `gameScene:draw()`

Draws the game. Called every frame.

**Drawing Order:**
1. Background color
2. Background layer
3. Coins, boxes, triggers, teleporters
4. Platforms, saws, spikes (with map color shader)
5. Player
6. Scene effects (transitions)

#### `gameScene:drawObjects(objects)`

Helper to draw a collection of objects.

**Parameters:**
- `objects` (table): Array or hash table of objects

#### `gameScene:keypressed(key)`

Handles key press events.

**Controls:**
- `R` - Reset level
- `Escape` - Pause game

## Properties

- `map` (table): Current map object
- `player` (player): Player object
- `camera` (camera): Camera object
- `deathTimer` (number): Timer for death restart
- `restarting` (boolean): Whether level is restarting
- `bindings` (baton): Input bindings

## Death System

When player dies:
1. Camera shakes
2. Death timer starts (1 second)
3. Level restarts with wipe transition
4. Player respawns at start

## Related Documentation

- [Player API](../objects/player.md)
- [Camera API](../core/camera.md)
- [Load Map API](../game/loadMap.md)
- [Scene Effects API](../systems/sceneEffects.md)

