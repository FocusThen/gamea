# Shaders System API

## Overview

The Shaders system manages post-processing shaders including CRT (Cathode Ray Tube) effects and color tinting. It provides a centralized way to enable/disable and configure shaders.

## Class: `shaders`

### Constructor

#### `shaders:new()`

Creates a new shaders system instance and loads all shaders.

**Example:**
```lua
local Shaders = require("src.systems.shaders")
shaderSystem = Shaders()
```

### Properties

- `enabled` (table): Dictionary of enabled states for each shader
- `intensity` (table): Dictionary of intensity values for each shaders
- `crtShader` (Shader|nil): CRT shader object
- `colorTintShader` (Shader|nil): Color tint shader object

### Methods

#### `shaders:loadShaders()`

Loads all shader files. Called automatically during initialization.

**Loaded Shaders:**
- `crt.glsl` - CRT/scanline effect
- `colorTint.glsl` - Color tinting effect

#### `shaders:toggle(name)`

Toggles a shader on/off.

**Parameters:**
- `name` (string): Shader name (`"crt"`)

**Example:**
```lua
shaderSystem:toggle("crt")
```

#### `shaders:setEnabled(name, enabled)`

Sets whether a shader is enabled.

**Parameters:**
- `name` (string): Shader name
- `enabled` (boolean): Enable state

**Example:**
```lua
shaderSystem:setEnabled("crt", true)
```

#### `shaders:setIntensity(name, intensity)`

Sets the intensity of a shader (0.0 to 1.0).

**Parameters:**
- `name` (string): Shader name
- `intensity` (number): Intensity value (clamped to 0-1)

**Example:**
```lua
shaderSystem:setIntensity("crt", 0.5)  -- 50% intensity
```

#### `shaders:apply(canvas, width, height)`

Applies shaders to a canvas. Currently returns canvas unchanged (CRT applied during draw).

**Parameters:**
- `canvas` (Canvas): Source canvas
- `width` (number): Canvas width
- `height` (number): Canvas height

**Returns:**
- `canvas` (Canvas): Processed canvas

#### `shaders:draw(canvas, x, y, scaleX, scaleY)`

Draws a canvas with shaders applied.

**Parameters:**
- `canvas` (Canvas): Canvas to draw
- `x` (number): X position
- `y` (number): Y position
- `scaleX` (number): X scale
- `scaleY` (number): Y scale

**Example:**
```lua
-- In main.lua love.draw()
shaderSystem:draw(worldCanvas, offsetX, offsetY, screen_scale, screen_scale)
```

#### `shaders:applyColorTint(color)`

Applies color tint shader with specified color.

**Parameters:**
- `color` (table): Color with `r`, `g`, `b` properties (0-1 range)

**Returns:**
- `applied` (boolean): `true` if shader was applied

**Example:**
```lua
-- Apply red tint
shaderSystem:applyColorTint({ r = 1.0, g = 0.0, b = 0.0 })

-- Draw with tint
love.graphics.draw(sprite, x, y)

-- Remove tint
shaderSystem:removeColorTint()
```

#### `shaders:removeColorTint()`

Removes color tint shader, restoring default shader.

## CRT Shader

The CRT shader provides a retro CRT monitor effect with:
- Scanlines
- Chromatic aberration
- Time-based effects

**Default State:**
- Enabled: `true`
- Intensity: `1.0`

**Shader Parameters:**
- `time` - Current time (for animation)
- `intensity` - Effect intensity (0-1)

## Color Tint Shader

The color tint shader applies a color overlay to drawn objects.

**Shader Parameters:**
- `tintColor` - RGB color values (0-1 range)

## Usage Examples

### Basic Shader Usage

```lua
-- In main.lua
function love.draw()
    love.graphics.setCanvas(worldCanvas)
    -- Draw game
    love.graphics.setCanvas()
    
    -- Draw with shaders
    shaderSystem:draw(worldCanvas, offsetX, offsetY, screen_scale, screen_scale)
end
```

### Toggling CRT Effect

```lua
-- In settings screen
if buttonPressed("Toggle CRT") then
    shaderSystem:toggle("crt")
end
```

### Adjusting CRT Intensity

```lua
-- In settings screen
local intensity = sliderValue  -- 0.0 to 1.0
shaderSystem:setIntensity("crt", intensity)
```

### Color Tinting Objects

```lua
-- Apply red tint to dangerous objects
shaderSystem:applyColorTint({ r = 1.0, g = 0.0, b = 0.0 })
for _, spike in ipairs(spikes) do
    spike:draw()
end
shaderSystem:removeColorTint()
```

### Map Color Tinting

```lua
-- In game state draw
if map.mapColor then
    shaderSystem:applyColorTint(map.mapColor)
end

-- Draw platforms, saws, spikes with tint
drawObjects(platforms)
drawObjects(saws)
drawObjects(spikes)

shaderSystem:removeColorTint()
```

## Shader Files

Shaders are located in `src/shaders/`:
- `crt.glsl` - CRT effect shader
- `colorTint.glsl` - Color tint shader
- `bloom.glsl` - Bloom effect (not yet integrated)
- `blur.glsl` - Blur effect (not yet integrated)

## Related Documentation

- [Constants API](../core/constants.md)
- [Rendering Pipeline](../../architecture/rendering-pipeline.md)
- [Game State](../states/game.md)

