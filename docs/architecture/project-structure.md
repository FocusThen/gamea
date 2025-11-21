# Project Structure

## Overview

This document describes the project's folder structure and organization.

## Directory Tree

```
game1/
├── assets/              # Game assets
│   ├── fonts/          # Font files
│   ├── music/          # Music tracks
│   ├── sounds/         # Sound effects
│   └── sprites/        # Sprite images
├── docs/               # Documentation
│   ├── api/            # API reference
│   ├── architecture/   # Architecture docs
│   ├── guides/         # User guides
│   └── viewer/        # Web documentation viewer
├── examples/           # Code examples
│   ├── camera/        # Camera examples
│   ├── objects/       # Object examples
│   ├── particles/     # Particle examples
│   ├── states/        # State examples
│   ├── systems/       # System examples
│   └── triggers/      # Trigger examples
├── lib/               # Third-party libraries
│   ├── anim8/         # Animation library
│   ├── baton/         # Input library
│   ├── bump/          # Physics library
│   ├── classic/       # OOP library
│   ├── flux/          # Tweening library
│   ├── json/          # JSON library
│   ├── lume/          # Utility library
│   ├── lurker/        # Hot reload library
│   └── sti/           # Tiled map library
├── maps/              # Level files
│   ├── level_*.lua    # Level data
│   └── level_*.tmx    # Tiled map files
├── src/               # Source code
│   ├── core/          # Core systems
│   │   ├── camera.lua
│   │   ├── colors.lua
│   │   ├── constants.lua
│   │   └── utils.lua
│   ├── game/          # Game logic
│   │   ├── loadMap.lua
│   │   └── resources.lua
│   ├── objects/       # Game objects
│   │   ├── box.lua
│   │   ├── coin.lua
│   │   ├── cutscene.lua
│   │   ├── door.lua
│   │   ├── player.lua
│   │   ├── saw.lua
│   │   ├── teleporter.lua
│   │   └── trigger.lua
│   ├── shaders/       # GLSL shaders
│   │   ├── bloom.glsl
│   │   ├── blur.glsl
│   │   ├── colorTint.glsl
│   │   └── crt.glsl
│   ├── states/        # Game states
│   │   ├── ending.lua
│   │   ├── game.lua
│   │   ├── intro.lua
│   │   ├── levelSelect.lua
│   │   ├── main_menu.lua
│   │   ├── pause.lua
│   │   ├── stateMachine.lua
│   │   └── title.lua
│   ├── systems/       # Systems
│   │   ├── inputConfig.lua
│   │   ├── particles.lua
│   │   ├── saveSystem.lua
│   │   ├── sceneEffects.lua
│   │   └── shaders.lua
│   └── ui/            # UI components
│       ├── settingsScreen.lua
│       └── utils.lua
├── build.sh           # Build script
├── conf.lua           # Love2D configuration
├── main.lua           # Entry point
└── README.md          # Project readme
```

## Key Directories

### `src/core/`

Core systems used throughout the game:
- Camera management
- Constants and configuration
- Color palette
- Utility functions

### `src/objects/`

Game objects that exist in the world:
- Player, boxes, coins
- Triggers, teleporters, doors
- Hazards (saws, spikes)
- Cutscenes

### `src/states/`

Game states (screens):
- Menu states
- Game state
- Pause state
- Ending state

### `src/systems/`

Global systems:
- Particle effects
- Shader management
- Save/load system
- Scene transitions
- Input configuration

## Related Documentation

- [Getting Started Guide](../guides/getting-started.md)
- [Architecture Overview](./architecture.md)

