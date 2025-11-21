# Scene Effects API

## Overview

The Scene Effects system provides transition effects for scene changes, including wipe and fade transitions. It uses flux for smooth animations.

## Class: `sceneEffects`

### Constructor

#### `sceneEffects:new(canvas)`

Creates a new scene effects system instance.

**Parameters:**
- `canvas` (Canvas): Canvas to draw effects on

**Example:**
```lua
local SceneEffects = require("src.systems.sceneEffects")
sceneEffects = SceneEffects(worldCanvas)
```

### Properties

- `canvas` (Canvas): Target canvas for effects
- `wipeEffectDuration` (number): Wipe transition duration (1.0 second)
- `wipeProgress` (table): Wipe progress (0 to 1, wrapped for flux)
- `wipeType` (boolean): `false` = wipe out, `true` = wipe in
- `wipeTween` (flux tween|nil): Active wipe tween
- `fadeEffectDuration` (number): Fade transition duration (3.0 seconds)
- `fadeAlpha` (table): Fade alpha value (0 to 1, wrapped for flux)
- `fadeTween` (flux tween|nil): Active fade tween

### Methods

#### `sceneEffects:setWipeIn()`

Starts a wipe-in effect (reveals scene).

#### `sceneEffects:setWipeOut()`

Starts a wipe-out effect (covers scene).

#### `sceneEffects:transitionToWithWipe(cb)`

Performs a complete wipe transition with callback.

**Parameters:**
- `cb` (function, optional): Callback executed when wipe-out completes

**Behavior:**
1. Wipes out (covers scene)
2. Executes callback
3. Wipes in (reveals new scene)

**Example:**
```lua
sceneEffects:transitionToWithWipe(function()
    -- Load new level
    self.map = loadLevel("level_2")
end)
```

#### `sceneEffects:setFadeIn()`

Starts a fade-in effect (reveals scene).

#### `sceneEffects:setFadeOut()`

Starts a fade-out effect (covers scene).

#### `sceneEffects:transitionToWithFade(cb)`

Performs a complete fade transition with callback.

**Parameters:**
- `cb` (function, optional): Callback executed when fade-out completes

**Behavior:**
1. Fades out (black screen)
2. Executes callback
3. Fades in (reveals new scene)

**Example:**
```lua
sceneEffects:transitionToWithFade(function()
    -- Teleport player
    player.x = newX
    player.y = newY
end)
```

#### `sceneEffects:drawWipePattern()`

Draws the wipe effect pattern. Called internally during draw.

#### `sceneEffects:draw()`

Draws active transition effects. Should be called every frame.

**Example:**
```lua
function love.draw()
    -- Draw game
    sceneEffects:draw()  -- Draw transitions on top
end
```

## Wipe Effect

The wipe effect uses sprite patterns to create a visual wipe transition:
- Uses `assets/sprites/wipe.png` and `assets/sprites/wipe2.png`
- Wipes horizontally from left to right
- Duration: 1.0 second (configurable)

## Fade Effect

The fade effect creates a smooth black fade transition:
- Fades to black (fade out)
- Fades from black (fade in)
- Duration: 3.0 seconds (configurable)

## Usage Examples

### Level Transition

```lua
-- In door:interact()
sceneEffects:transitionToWithWipe(function()
    local nextLevel = "level_" .. (currentLevel + 1)
    self.map = loadLevel(nextLevel)
    self.player = self.map.entities.player
end)
```

### Player Death Restart

```lua
-- In game state
if player.dead then
    sceneEffects:transitionToWithWipe(function()
        self.map = loadLevel(self.map.path)  -- Reload current level
        self.player = self.map.entities.player
    end)
end
```

### Teleporter Transition

```lua
-- In teleporter:interact()
sceneEffects:transitionToWithFade(function()
    player.x = destX
    player.y = destY
    World:update(player, player.x, player.y)
end)
```

### Manual Wipe Control

```lua
-- Start wipe out
sceneEffects:setWipeOut()

-- Later, start wipe in
sceneEffects:setWipeIn()
```

## Related Documentation

- [Constants API](../core/constants.md)
- [Door API](../objects/door.md)
- [Teleporter API](../objects/teleporter.md)
- [Game State](../states/game.md)

