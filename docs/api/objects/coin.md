# Coin API

## Overview

The Coin object represents a collectible pickup that the player can collect. Coins are automatically removed when touched by the player.

## Class: `coin`

### Constructor

#### `coin:new(x, y)`

Creates a new coin instance.

**Parameters:**
- `x` (number): Initial X position
- `y` (number): Initial Y position

**Example:**
```lua
local Coin = require("src.objects.coin")
local coin = Coin(100, 200)
```

### Properties

- `x`, `y` (number): Position coordinates
- `width`, `height` (number): Collision dimensions (8x8)
- `type` (string): Always `"pickup"`
- `pickType` (string): Always `"coin"`
- `delete` (boolean): Deletion flag (set to `true` on pickup)
- `drawOffX`, `drawOffY` (number): Drawing offsets (currently 0)

### Methods

#### `coin:update(dt)`

Updates coin state. Currently does nothing but can be used for animations.

**Parameters:**
- `dt` (number): Delta time

#### `coin:draw()`

Draws the coin as a yellow filled rectangle.

#### `coin:onPickup()`

Called when player collects the coin. Plays coin sound.

**Example:**
```lua
-- Called automatically by player collision system
coin:onPickup()  -- Plays sound, sets delete flag
```

## Pickup System

### Automatic Collection

Coins are automatically collected when the player touches them:
1. Player collision detected
2. `onPickup()` called
3. `delete` flag set to `true`
4. Removed from physics world
5. Removed from entities list in next update cycle

## Usage Example

```lua
-- In loadMap.lua
local Coin = require("src.objects.coin")
local coin = Coin(spawnX, spawnY)

-- In game state (coins handled automatically)
function gameScene:update(dt)
    -- Coins are processed in player collision
    -- Remove deleted coins
    for i = #map.entities.coins, 1, -1 do
        if map.entities.coins[i].delete then
            table.remove(map.entities.coins, i)
        end
    end
end
```

## Customization

### Adding Animation

```lua
function coin:new(x, y)
    -- ... existing code ...
    
    -- Add animation
    self.sprite = sprites.coin
    local grid = anim8.newGrid(16, 16, self.sprite:getWidth(), self.sprite:getHeight())
    self.anim = anim8.newAnimation(grid("1-7", 1), 0.1)
end

function coin:update(dt)
    self.anim:update(dt)
end

function coin:draw()
    self.anim:draw(self.sprite, self.x, self.y)
end
```

## Related Documentation

- [Constants API](../core/constants.md)
- [Player API](./player.md)
- [Resources API](../game/resources.md)

