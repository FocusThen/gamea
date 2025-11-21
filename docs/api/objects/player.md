# Player API

## Overview

The Player object represents the main controllable character in the game. It handles input, movement, physics, abilities (double jump, dash), and interactions with game objects.

## Class: `player`

### Constructor

#### `player:new(x, y, props)`

Creates a new player instance with spawn combination animation.

**Parameters:**

- `x` (number): Initial X position
- `y` (number): Initial Y position
- `props` (table, optional): Properties from Tiled map
  - `doubleJump` (boolean): Enable double jump ability
  - `dash` (boolean): Enable dash ability

**Behavior:**
1. Initializes player at spawn position
2. Player starts invisible (`visible = false`)
3. Player starts in spawning state (`spawning = true`)
4. Creates spawn combination effect (6 rectangular pieces come together)
5. When particles combine, player becomes visible and can move

**Example:**

```lua
local Player = require("src.objects.player")
local player = Player(100, 200, { doubleJump = true, dash = true })
```

### Properties

**Position & Physics:**

- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Collision dimensions
- `xVel`, `yVel` (number): Velocity components
- `gravity` (number): Gravity acceleration
- `friction` (number): Ground friction

**Movement:**

- `speed` (number): Horizontal movement speed
- `jump` (number): Jump velocity (negative = upward)
- `dash` (number): Dash speed
- `facing` (boolean): `true` = right, `false` = left

**Abilities:**

- `abilities.doubleJump` (boolean): Double jump enabled
- `abilities.dash` (boolean): Dash enabled
- `airJump` (boolean): Whether air jump is available
- `dashUp` (boolean): Whether dash can be used

**State:**

- `dead` (boolean): Whether player is dead
- `coyote` (number): Coyote time remaining
- `jumpWhenAble` (number): Delayed jump timer
- `jumpEffectQueued` (boolean): Queue jump particle effect
- `visible` (boolean): Whether player is visible (used for teleport/spawn effects)
- `teleporting` (boolean): Whether player is currently teleporting
- `spawning` (boolean): Whether player is currently spawning

**Drawing:**

- `drawOffXRight`, `drawOffXLeft` (number): Sprite X offsets
- `drawOffY` (number): Sprite Y offset

### Methods

#### `player:update(dt)`

Updates player state, handles input, physics, and collisions. Called every frame.

**Parameters:**

- `dt` (number): Delta time

**Behavior:**
- Returns early if player is teleporting or spawning (prevents movement during animations)
- Handles input, movement, physics, and collisions when active
- Processes teleportation if `teleportedX` and `teleportedY` are set

**Example:**

```lua
function gameScene:update(dt)
    player:update(dt)
end
```

#### `player:draw()`

Draws the player. Currently draws a simple black rectangle. Only draws if player is visible.

**Behavior:**
- Returns early if `visible` is `false` (used during teleport/spawn/death animations)
- Draws black rectangle at player position

**Example:**

```lua
function gameScene:draw()
    player:draw()
end
```

#### `player:checkGrounded()`

Checks if the player is standing on a surface.

**Returns:**

- `grounded` (boolean): `true` if player is on ground

**Example:**

```lua
if player:checkGrounded() then
    -- Player can jump
end
```

#### `player:kill()`

Kills the player, triggering death sound, death explosion particles, and death state.

**Behavior:**
1. Sets `dead` flag to `true`
2. Plays death sound
3. Hides player
4. Creates death explosion effect (6 rectangular pieces explode outward)
5. Player stays hidden after explosion

**Example:**

```lua
if playerHitSpike then
    player:kill()
end
```

#### `player:doJump()`

Performs a jump action, setting vertical velocity and creating jump effects.

**Example:**

```lua
player:doJump()  -- Called internally on jump input
```

#### `player:controls()`

Creates and returns the input control configuration using baton.

**Returns:**

- `input` (baton object): Input handler

**Controls:**

- `left`: Left arrow, A key, left stick left
- `right`: Right arrow, D key, left stick right
- `jump`: Up arrow, W key, A button, left stick up
- `dash`: Spacebar
- `down`: Down arrow, S key, left stick down

## Movement System

### Horizontal Movement

Player moves horizontally based on input:

- Left/Right input moves at `speed` pixels/second
- Friction applies when not moving
- Velocity-based movement for dash

### Vertical Movement

- Gravity constantly applied
- Jump sets negative `yVel`
- Coyote time allows jump shortly after leaving ground
- Double jump available if ability enabled

### Dash

- Horizontal dash at `dash` speed
- Only available when `dashUp` is true
- Creates dash particle effect
- Resets on ground or spring bounce

## Collision Handling

### Collision Types

The player's filter function handles different collision types:

- `pickup`, `spike`, `door`, `trigger`, `saw`, `teleporter`: Cross (no collision)
- `oneWay`: One-way platform
- `spring`: Slide collision
- `platform`: Slide collision

### Interactions

**Boxes:**

- Can push boxes horizontally
- Can jump on boxes from below
- Boxes can push player up

**Springs:**

- Bounces player if velocity is high enough
- Stores bounce velocity for consistent height
- Enables dash after bounce

**Platforms:**

- Slip detection for smooth platforming
- Handles vertical and horizontal collisions

## Visual Effects

### Spawn Combination

When a player spawns (level start or restart):
- Player starts invisible
- 6 rectangular pieces come together from scattered positions
- Pieces fade in as they combine
- Duration: 0.4 seconds
- Player becomes visible and can move when complete

### Death Explosion

When a player dies:
- Player becomes invisible
- 6 rectangular pieces explode outward in different directions
- Pieces fade out as they move
- Duration: 0.5 seconds
- Player stays hidden after explosion

### Teleportation

When teleporting (see [Teleporter API](./teleporter.md)):
- Player becomes invisible
- 6 rectangular pieces travel from source to destination
- Player reforms at destination when particles arrive

## Abilities

### Double Jump

```lua
-- Enable in Tiled
player.abilities.doubleJump = true

-- Player can jump once in the air
```

### Dash

```lua
-- Enable in Tiled
player.abilities.dash = true

-- Press spacebar to dash horizontally
```

## Usage Example

```lua
-- In loadMap.lua
local Player = require("src.objects.player")
local player = Player(spawnX, spawnY, {
    doubleJump = props.doubleJump or false,
    dash = props.dash or false
})

-- In game state
function gameScene:update(dt)
    player:update(dt)
    camera:setTarget(player.x + player.width / 2, player.y + player.height / 2)
end

function gameScene:draw()
    camera:apply()
    player:draw()
    camera:unapply()
end
```

## Related Documentation

- [Constants API](../core/constants.md)
- [Input Config](../systems/inputConfig.md)
- [Particles System](../systems/particles.md)
- [Camera API](../core/camera.md)
