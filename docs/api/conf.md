# Configuration API

## Overview

The `conf.lua` file configures Love2D window and game settings. It's loaded automatically by Love2D before `main.lua`.

## Global Variables

### `DEBUG`

Debug mode flag. Set to `false` for production.

### `isDev`

Development mode flag. Enables dev features like hot reloading.

## Function: `love.conf(t)`

Configures Love2D window and system settings.

**Parameters:**
- `t` (table): Love2D configuration table

**Configuration:**
```lua
function love.conf(t)
    t.version = "11.5"              -- Love2D version
    t.identity = "game1"            -- Save directory name
    t.window.title = "Game 1"       -- Window title
    t.window.icon = nil             -- Window icon (none)
    t.window.vsync = 1              -- VSync enabled
    t.window.highdpi = true         -- High DPI support
    t.window.width = 624            -- Window width
    t.window.height = 672           -- Window height
    t.window.minwidth = 416         -- Minimum width
    t.window.minheight = 448        -- Minimum height
    t.window.resizable = true       -- Window resizable
end
```

## Settings

### Window Size

- **Width**: 624 pixels
- **Height**: 672 pixels
- **Minimum Width**: 416 pixels
- **Minimum Height**: 448 pixels

### Window Options

- **VSync**: Enabled (1)
- **High DPI**: Enabled
- **Resizable**: Enabled

### Save Directory

- **Identity**: `"game1"`
- Save files stored in Love2D's save directory under this name

## Development Settings

For development:
```lua
DEBUG = false
isDev = true
```

For production:
```lua
DEBUG = false
isDev = false
```

## Related Documentation

- [Main API](./main.md)
- [Love2D Configuration](https://love2d.org/wiki/Config_Files)

