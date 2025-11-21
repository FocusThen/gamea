# Box API

## Overview

The Box object represents a pushable physics object that responds to gravity, friction, and player interactions. Boxes can be pushed by the player and bounce on springs.

## Class: `box`

### Constructor

#### `box:new(x, y)`

Creates a new box instance.

**Parameters:**

- `x` (number): Initial X position
- `y` (number): Initial Y position

**Example:**

```lua
local Box = require("src.objects.box")
local box = Box(100, 200)
```

### Properties

- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Collision dimensions (16x16)
- `xVel`, `yVel` (number): Velocity components
- `gravity` (number): Gravity acceleration (800)
- `friction` (number): Ground friction (665)
- `lastBounce` (number|nil): Stored bounce velocity for springs
- `type` (string): Always `"box"`
- `delete` (boolean): Deletion flag

### Methods

#### `box:update(dt)`

Updates box physics, movement, and collisions. Called every frame.

**Parameters:**

- `dt` (number): Delta time

**Physics:**

- Applies gravity to `yVel`
- Applies friction to `xVel` when grounded
- Air friction when not grounded
- Handles spring bounces
- Processes collisions with player

#### `box:draw()`

Draws the box as a cyan outlined rectangle.

#### `box:checkGrounded()`

Checks if the box is standing on a surface.

**Returns:**

- `grounded` (boolean): `true` if box is on ground

## Physics Behavior

### Gravity

Boxes fall at `Constants.BOX.GRAVITY` (800 pixels/second²).

### Friction

- **Ground Friction**: `Constants.BOX.FRICTION` (665) when grounded
- **Air Friction**: `Constants.BOX.FRICTION_AIR` (33.25) when airborne
- Friction only applies above velocity threshold

### Spring Interaction

- Bounces if `yVel > Constants.VELOCITY.BOX_SPRING_BOUNCE_MIN` (50)
- Stores bounce velocity for consistent bounce height
- Plays spring sound and animation

### Player Interaction

- Player can push boxes horizontally
- Boxes can be pushed by player velocity
- Player can jump on boxes from below
- Boxes push player up when jumped on

## Usage Example

```lua
-- In loadMap.lua
local Box = require("src.objects.box")
local box = Box(spawnX, spawnY)

-- In game state
function gameScene:update(dt)
    for _, box in ipairs(map.entities.boxes) do
        box:update(dt)
    end
end

function gameScene:draw()
    for _, box in ipairs(map.entities.boxes) do
        box:draw()
    end
end
```

## Related Documentation

- [Constants API](../core/constants.md)
- [Player API](./player.md)
