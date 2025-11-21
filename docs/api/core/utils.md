# Utils API

## Overview

The Utils module provides utility functions used throughout the game, including deep copying, level counting, and color parsing.

## Module Functions

### `deepcopy(orig)`

Creates a deep copy of a table, recursively copying all nested tables and preserving metatables.

**Parameters:**
- `orig` (table): The table to copy

**Returns:**
- `copy` (table): A deep copy of the original table

**Example:**
```lua
local utils = require("src.core.utils")

local original = {
    x = 10,
    nested = { a = 1, b = 2 }
}

local copy = deepcopy(original)
copy.nested.a = 999  -- Original is not affected
print(original.nested.a)  -- Still 1
```

**Use Cases:**
- Copying particle effect animations
- Duplicating configuration objects
- Creating independent copies of game objects

### `countAvailableLevels()`

Counts the number of level files available in the `maps/` directory.

**Returns:**
- `count` (number): Number of level files found (files matching `level_*.lua`)

**Example:**
```lua
local levelCount = countAvailableLevels()
print("Available levels: " .. levelCount)
```

**Implementation Notes:**
- Safely handles cases where filesystem is not available
- Only counts files matching pattern `level_%d+.lua`
- Returns 0 on error or if no levels found

### `parseColorProperty(value)`

Parses a color string (hex format) into normalized RGBA values.

**Parameters:**
- `value` (string): Color string in hex format (#RRGGBB or #AARRGGBB)

**Returns:**
- `color` (table|nil): Color table with `r`, `g`, `b`, `a` properties (0-1 range), or `nil` if invalid

**Color Formats Supported:**
- `#RRGGBB` - 6-digit hex (alpha defaults to 1.0)
- `#AARRGGBB` - 8-digit hex with alpha
- `0xRRGGBB` - Alternative hex format
- `0xAARRGGBB` - Alternative hex format with alpha

**ARGB vs RGBA:**
The function automatically detects ARGB vs RGBA format:
- If first byte is 0 or 255 and last byte is not, assumes ARGB
- Otherwise assumes RGBA

**Example:**
```lua
-- Parse 6-digit hex
local color = parseColorProperty("#FF0000")  -- Red
-- Returns: { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }

-- Parse 8-digit hex with alpha
local color = parseColorProperty("#80FF0000")  -- Semi-transparent red (ARGB)
-- Returns: { r = 1.0, g = 0.0, b = 0.0, a = 0.5 }

-- Parse RGBA format
local color = parseColorProperty("#FF000080")  -- Semi-transparent red (RGBA)
-- Returns: { r = 1.0, g = 0.0, b = 0.0, a = 0.5 }

-- Invalid color returns nil
local color = parseColorProperty("invalid")
-- Returns: nil
```

**Use Cases:**
- Parsing Tiled map color properties
- Converting hex colors from external tools
- Loading color data from configuration files

## Usage Examples

### Deep Copy for Particle Effects

```lua
-- Create particle effect template
local effectTemplate = {
    anim = anim8.newAnimation(...),
    sheet = spriteSheet,
    x = 0,
    y = 0
}

-- Create multiple instances
for i = 1, 10 do
    local effect = deepcopy(effectTemplate)
    effect.x = math.random(100, 200)
    effect.y = math.random(100, 200)
    table.insert(activeEffects, effect)
end
```

### Level Selection Screen

```lua
function levelSelect:new()
    local levelCount = countAvailableLevels()
    
    for i = 1, levelCount do
        local levelButton = {
            level = i,
            unlocked = i <= savedGame.levelReached
        }
        table.insert(self.levels, levelButton)
    end
end
```

### Tiled Color Parsing

```lua
-- In loadMap.lua
local bgColor = map.properties.bgColor
if bgColor then
    local color = parseColorProperty(bgColor)
    if color then
        map.bgColor = color
    end
end
```

## Related Documentation

- [Load Map API](../game/loadMap.md)
- [Particles System](../systems/particles.md)

