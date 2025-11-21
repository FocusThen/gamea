# Colors API

## Overview

The Colors module provides a centralized color palette for consistent theming across the game. All colors are defined in normalized RGB format (0-1 range) for use with Love2D's graphics functions.

## Module: `Colors`

### Background Colors

```lua
Colors.BACKGROUND = {20 / 255, 24 / 255, 46 / 255, 1}
-- Dark blue/purple background color
```

### Text Colors

```lua
Colors.TEXT_PRIMARY = {146 / 255, 232 / 255, 192 / 255, 1}  -- Mint green
Colors.TEXT_SECONDARY = {240 / 255, 181 / 255, 65 / 255, 1}  -- Orange
Colors.TEXT_DARK = {43 / 255, 43 / 255, 69 / 255, 1}  -- Dark blue/purple
```

### UI Colors

```lua
Colors.SELECTION = {0, 1, 1, 1}  -- Cyan highlight
Colors.WHITE = {1, 1, 1, 1}      -- White
Colors.GREY = {0.5, 0.5, 0.5, 1}  -- Grey
```

## Usage

### Setting Colors

```lua
local Colors = require("src.core.colors")

-- Set background color
love.graphics.setColor(Colors.BACKGROUND)
love.graphics.rectangle("fill", 0, 0, width, height)

-- Set text color
love.graphics.setColor(Colors.TEXT_PRIMARY)
love.graphics.print("Hello World", x, y)

-- Set selection highlight
love.graphics.setColor(Colors.SELECTION)
love.graphics.rectangle("line", x, y, width, height)
```

### Color Format

All colors are in RGBA format with values normalized to 0-1:

- Red: 0.0 to 1.0
- Green: 0.0 to 1.0
- Blue: 0.0 to 1.0
- Alpha: 0.0 to 1.0 (1.0 = fully opaque)

### Example: Menu Rendering

```lua
function menu:draw()
    -- Background
    love.graphics.setColor(Colors.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, width, height)

    -- Menu items
    for i, item in ipairs(self.items) do
        if i == self.selectedIndex then
            love.graphics.setColor(Colors.SELECTION)
        else
            love.graphics.setColor(Colors.TEXT_PRIMARY)
        end
        love.graphics.print(item.text, x, y + i * spacing)
    end
end
```

## Color Palette

### Primary Colors

- **Mint Green** (`TEXT_PRIMARY`): Primary text and UI elements
- **Orange** (`TEXT_SECONDARY`): Secondary text and highlights
- **Cyan** (`SELECTION`): Selection indicators and highlights

### Background

- **Dark Blue/Purple** (`BACKGROUND`): Main background color

### Utility

- **White** (`WHITE`): General white color
- **Grey** (`GREY`): Neutral grey color
- **Dark Blue/Purple** (`TEXT_DARK`): Dark text on light backgrounds

## Custom Colors

To add custom colors, extend the Colors module:

```lua
-- In colors.lua
Colors.ENEMY = {1, 0, 0, 1}  -- Red for enemies
Colors.POWERUP = {1, 1, 0, 1}  -- Yellow for powerups
```

## Related Documentation

- [UI Utils](../ui/utils.md)
- [Settings Screen](../ui/settingsScreen.md)
