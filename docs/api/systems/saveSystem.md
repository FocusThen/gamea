# Save System API

## Overview

The Save System handles saving and loading game progress, settings, and shader preferences. It uses JSON format for storage and Love2D's filesystem API.

## Class: `saveSystem`

### Constructor

#### `saveSystem:new()`

Creates a new save system instance.

**Example:**
```lua
local SaveSystem = require("src.systems.saveSystem")
saveSystem = SaveSystem()
```

### Properties

- `saveFilePath` (string): Path to save file (`"savegame.json"`)

### Methods

#### `saveSystem:hasSave()`

Checks if a save file exists.

**Returns:**
- `hasSave` (boolean): `true` if save file exists

**Example:**
```lua
if saveSystem:hasSave() then
    -- Load existing save
else
    -- Start new game
end
```

#### `saveSystem:saveGame()`

Saves game state to file.

**Saved Data:**
- `levelReached` - Highest level reached
- `settings.masterVol` - Master volume
- `settings.musicVol` - Music volume
- `settings.sfxVol` - SFX volume
- `settings.gameWidth` - Game width
- `settings.gameHeight` - Game height
- `shaderSettings.crtEnabled` - CRT shader enabled state

**Example:**
```lua
-- Save on level completion
saveSystem:saveGame()

-- Save on settings change
saveSystem:saveGame()
```

#### `saveSystem:loadGame()`

Loads game state from file.

**Returns:**
- `success` (boolean): `true` if load was successful

**Behavior:**
- Restores `savedGame.levelReached`
- Restores `gameSettings` values
- Restores shader settings

**Example:**
```lua
-- In love.load()
saveSystem:loadGame()  -- Load on startup
```

## Save File Format

The save file is JSON format:

```json
{
    "levelReached": 3,
    "settings": {
        "masterVol": 1.0,
        "musicVol": 0.7,
        "sfxVol": 0.5,
        "gameWidth": 320,
        "gameHeight": 192
    },
    "shaderSettings": {
        "crtEnabled": true
    }
}
```

## Usage Examples

### Saving on Level Complete

```lua
-- In door:interact()
if isLastLevel then
    saveSystem:saveGame()
    stateMachine:setState("ending")
else
    saveSystem:saveGame()  -- Auto-save on level completion
    stateMachine:setState("game", { map = loadLevel(nextLevel) })
end
```

### Loading on Startup

```lua
function love.load()
    -- Initialize systems
    saveSystem = SaveSystem()
    
    -- Load saved game
    saveSystem:loadGame()
    
    -- Start game
    stateMachine:setState("main_menu")
end
```

### Checking for Save File

```lua
-- In level select
if saveSystem:hasSave() then
    -- Show continue option
    maxLevel = savedGame.levelReached
else
    -- Start from level 1
    maxLevel = 1
end
```

## File Location

Save files are stored in Love2D's save directory:
- Windows: `%APPDATA%/LOVE/game1/`
- macOS: `~/Library/Application Support/LOVE/game1/`
- Linux: `~/.local/share/love/game1/`

## Error Handling

The save system uses `pcall` for error handling:
- File read/write errors are caught
- JSON parse errors are caught
- Errors are printed to console
- Functions return `false` on error

## Related Documentation

- [Door API](../objects/door.md)
- [Game Settings](../../architecture/project-structure.md)
- [JSON Library](../../architecture/project-structure.md)

