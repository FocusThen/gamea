# Getting Started

## Quick Start

This guide will help you get started with the game template.

## Prerequisites

- Love2D 11.5 installed
- Tiled Map Editor (for level creation)
- Text editor (VS Code, Sublime Text, etc.)

## Project Structure

```
game1/
├── assets/          # Sprites, sounds, fonts, music
├── docs/            # Documentation
├── examples/        # Code examples
├── lib/             # Third-party libraries
├── maps/            # Level files
├── src/             # Source code
│   ├── core/        # Core systems (camera, constants, etc.)
│   ├── game/        # Game logic (map loading, resources)
│   ├── objects/     # Game objects (player, boxes, triggers, etc.)
│   ├── shaders/     # GLSL shader files
│   ├── states/      # Game states (menu, game, pause, etc.)
│   ├── systems/     # Systems (particles, shaders, save, etc.)
│   └── ui/          # UI components
├── main.lua         # Entry point
└── conf.lua         # Configuration
```

## Running the Game

1. Open terminal in project directory
2. Run: `love .`
3. Game should start

## Creating Your First Level

1. Open Tiled Map Editor
2. Create new map (320x192 pixels, tile size 16x16)
3. Create layers: "Platforms", "Spawns", "Dangers", "Bg"
4. Add a player object in "Spawns" layer (name: `player`)
5. Add platforms in "Platforms" layer
6. Export as Lua file to `maps/level_1.lua`
7. Run the game

## Next Steps

- Read [Tiled Integration Guide](./tiled-integration.md) for detailed level creation
- Check [Examples](../examples/) for code samples
- Read [API Documentation](../api/) for system details

## Related Documentation

- [Tiled Integration Guide](./tiled-integration.md)
- [Architecture Overview](./architecture.md)
- [Project Structure](../architecture/project-structure.md)

