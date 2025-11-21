# Input Config API

## Overview

The Input Config module provides standardized input bindings for menus and common controls. It uses the baton library for input handling and supports keyboard, gamepad, and joystick input.

## Module: `inputConfig`

### Common Menu Controls

The module provides a standard set of menu controls:

```lua
inputConfig.commonMenuControls = {
    up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
    down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
    left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
    right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
    select = { "key:space", "key:return", "key:z", "button:a" },
    quit = { "key:escape", "button:b" },
    back = { "key:escape", "button:b" },
    continue_key = { "key:space", "key:return", "key:z", "button:a" },
}
```

### Functions

#### `inputConfig.createMenuBindings()`

Creates a baton input handler with standard menu controls.

**Returns:**
- `bindings` (baton object): Input handler

**Example:**
```lua
local inputConfig = require("src.systems.inputConfig")

function menuState:new()
    self.bindings = inputConfig.createMenuBindings()
end

function menuState:update(dt)
    self.bindings:update()
    
    if self.bindings:pressed("up") then
        -- Move selection up
    end
    
    if self.bindings:pressed("select") then
        -- Select item
    end
end
```

#### `inputConfig.createSimpleBindings(controls)`

Creates a baton input handler with custom controls.

**Parameters:**
- `controls` (table): Custom controls table

**Returns:**
- `bindings` (baton object): Input handler

**Example:**
```lua
local bindings = inputConfig.createSimpleBindings({
    jump = { "key:space", "button:a" },
    attack = { "key:x", "button:x" }
})
```

## Input Format

Controls use baton's input format:
- `"key:name"` - Keyboard key (e.g., `"key:space"`, `"key:up"`)
- `"button:name"` - Gamepad button (e.g., `"button:a"`, `"button:b"`)
- `"axis:name+"` - Positive axis direction (e.g., `"axis:leftx+"`)
- `"axis:name-"` - Negative axis direction (e.g., `"axis:lefty-"`)

## Usage Examples

### Menu Navigation

```lua
function menuState:new()
    self.bindings = inputConfig.createMenuBindings()
    self.selectedIndex = 1
end

function menuState:update(dt)
    self.bindings:update()
    
    if self.bindings:pressed("up") then
        self.selectedIndex = math.max(1, self.selectedIndex - 1)
    elseif self.bindings:pressed("down") then
        self.selectedIndex = math.min(#self.items, self.selectedIndex + 1)
    end
    
    if self.bindings:pressed("select") then
        self:selectItem(self.selectedIndex)
    end
    
    if self.bindings:pressed("back") then
        self:goBack()
    end
end
```

### Custom Controls

```lua
function gameState:new()
    self.bindings = inputConfig.createSimpleBindings({
        reset = { "key:r" },
        pause = { "key:escape", "button:start" }
    })
end
```

### Player Controls

Player controls are defined in `player.lua`:

```lua
function player:controls()
    return baton.new({
        controls = {
            left = { "key:left", "key:a", "axis:leftx-" },
            right = { "key:right", "key:d", "axis:leftx+" },
            jump = { "key:up", "key:w", "button:a", "axis:lefty-" },
            dash = { "key:space" },
            down = { "key:down", "key:s", "axis:lefty+" },
        },
        joystick = love.joystick.getJoysticks()[1],
    })
end
```

## Related Documentation

- [Baton Library](https://github.com/tesselode/baton)
- [Player API](../objects/player.md)
- [State Machine](../states/stateMachine.md)

