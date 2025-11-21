# Trigger API

## Overview

The Trigger system provides a flexible event-driven mechanism for game object interactions. Triggers can move, scale, activate, and sequence actions on target entities when activated by player collision or timers.

**For comprehensive documentation, see [Trigger System Guide](../../guides/trigger-system.md)**

## Class: `trigger`

### Constructor

#### `trigger:new(x, y, width, height, props)`

Creates a new trigger instance.

**Parameters:**
- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Trigger collision area
- `props` (table, optional): Properties from Tiled map

**Properties:**
- `action` (string): Action type - `"move"`, `"scale"`, `"activate"`, `"sequence"`, `"cutscene"`, `"timer"` (default: `"move"`)
- `targetId` (number|object reference): ID of target object
- `moveX`, `moveY` (number): Movement distance
- `scale`, `scaleX`, `scaleY` (number): Scaling values
- `speed` (number): Movement speed (pixels/second)
- `duration` (number): Action duration (seconds)
- `delay` (number): Delay before action starts
- `once` (boolean): Whether trigger activates only once (default: `true`)
- `timerDelay` (number): Auto-activation delay for timer triggers

### Methods

#### `trigger:activate()`

Activates the trigger, executing its action.

#### `trigger:interact(player)`

Called when player collides with trigger.

**Parameters:**
- `player` (player object): The player

#### `trigger:update(dt)`

Updates trigger state (movement, scaling, timers).

#### `trigger:doMove()`

Executes move action on target.

#### `trigger:doScale()`

Executes scale action on target.

#### `trigger:doActivate()`

Activates target trigger/object.

#### `trigger:doSequence()`

Starts sequence execution.

#### `trigger:doCutscene()`

Starts cutscene.

## Action Types

### Move Action

Moves target entity smoothly.

```lua
trigger.action = "move"
trigger.targetId = boxId
trigger.moveX = 100
trigger.moveY = 0
trigger.speed = 50  -- or duration = 2.0
```

### Scale Action

Scales target entity smoothly.

```lua
trigger.action = "scale"
trigger.targetId = boxId
trigger.scale = 0.5  -- Shrink to half size
trigger.duration = 1.0
```

### Activate Action

Activates another trigger or object.

```lua
trigger.action = "activate"
trigger.targetId = otherTriggerId
```

### Sequence Action

Executes multiple actions in sequence.

```lua
trigger.action = "sequence"
trigger.sequence = {
    { action = "move", moveX = 100, duration = 1.0 },
    { action = "wait", delay = 0.5 },
    { action = "scale", scale = 0.5, duration = 1.0 }
}
```

### Timer Action

Auto-activates after delay.

```lua
trigger.action = "timer"
trigger.timerDelay = 3.0  -- Activate after 3 seconds
```

### Cutscene Action

Triggers a cutscene.

```lua
trigger.action = "cutscene"
trigger.cutscene = {
    { type = "wait", duration = 1.0 },
    { type = "showText", text = "Hello!", duration = 3.0 }
}
```

## Related Documentation

- [Trigger System Guide](../../guides/trigger-system.md) - Comprehensive guide
- [Tiled Integration Guide](../../guides/tiled-integration.md)
- [Cutscene API](./cutscene.md)

