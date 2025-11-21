# State Machine API

## Overview

The State Machine manages game states and handles transitions between them. It provides a centralized system for state management, ensuring proper initialization, cleanup, and event forwarding.

## Class: `stateMachine`

### Constructor

#### `stateMachine:new()`

Creates a new state machine instance and loads all game states.

**Example:**
```lua
local StateMachine = require("src.states.stateMachine")
stateMachine = StateMachine()
```

### Properties

- `states` (table): Dictionary of all loaded states
- `currentState` (string|nil): Name of currently active state

### Methods

#### `stateMachine:loadStates()`

Loads all game states. Called automatically during initialization.

**Loaded States:**
- `intro` - Introduction screen
- `main_menu` - Main menu
- `title` - Title screen (backward compatibility)
- `game` - Main game state
- `levelSelect` - Level selection screen
- `pause` - Pause menu
- `ending` - Ending screen

#### `stateMachine:setState(stateName, enterparams)`

Switches to a new state.

**Parameters:**
- `stateName` (string): Name of state to switch to
- `enterparams` (table, optional): Parameters passed to state's `enter()` method

**Behavior:**
1. Calls `exit()` on current state if it exists
2. Sets new current state
3. Calls `enter()` on new state with `enterparams`

**Example:**
```lua
-- Switch to game state with map
stateMachine:setState("game", { map = loadedMap })

-- Switch to menu
stateMachine:setState("main_menu")
```

#### `stateMachine:update(dt)`

Updates the current state. Forwards `update()` call to active state.

**Parameters:**
- `dt` (number): Delta time

#### `stateMachine:draw()`

Draws the current state. Forwards `draw()` call to active state.

#### `stateMachine:keypressed(key)`

Handles key press events. Forwards to current state.

**Parameters:**
- `key` (string): Key name

#### `stateMachine:keyreleased(key)`

Handles key release events. Forwards to current state.

**Parameters:**
- `key` (string): Key name

## State Interface

All states should implement these methods (optional):

### `state:enter(enterparams)`

Called when state becomes active.

**Parameters:**
- `enterparams` (table, optional): Parameters from `setState()`

### `state:exit()`

Called when state is being left.

### `state:update(dt)`

Called every frame while state is active.

**Parameters:**
- `dt` (number): Delta time

### `state:draw()`

Called every frame to draw the state.

### `state:keypressed(key)`

Called when a key is pressed.

**Parameters:**
- `key` (string): Key name

### `state:keyreleased(key)`

Called when a key is released.

**Parameters:**
- `key` (string): Key name

## Usage Example

### Creating a Custom State

```lua
local myState = Object:extend()

function myState:new()
    -- Initialize state
end

function myState:enter(params)
    -- Called when entering state
    if params then
        -- Use params
    end
end

function myState:exit()
    -- Cleanup
end

function myState:update(dt)
    -- Update logic
end

function myState:draw()
    -- Drawing logic
end

return myState
```

### Using the State Machine

```lua
-- In main.lua
stateMachine = StateMachine()

-- In game code
stateMachine:setState("game", { map = map })
stateMachine:setState("pause")
stateMachine:setState("main_menu")
```

## State Flow

```
Main Menu
    ↓
Level Select
    ↓
Game (with map)
    ↓
Pause (overlay)
    ↓
Game (resume)
    ↓
Door → Next Level or Ending
```

## Related Documentation

- [Game State](./game.md)
- [Main Menu State](./main_menu.md)
- [Level Select State](./levelSelect.md)
- [Pause State](./pause.md)
- [Architecture: State Management](../../architecture/state-management.md)

