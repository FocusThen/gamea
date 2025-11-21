# Game 1

A platformer game built with LÖVE (Love2D).

## Building and Distribution

This project uses `love-release` to create distributable builds for multiple platforms.

### Prerequisites

- LÖVE 11.5 installed
- `love-release` installed (via luarocks: `luarocks install love-release`)

### Building

Simply run the build script:

```bash
./build.sh
```

This will:
1. Create a `.love` file (compatible with LÖVE installations)
2. Create platform-specific executables using `love-release`
3. Output all files to the `releases/` directory

### Build Output

After running `build.sh`, you'll find:
- `game1.love` - LÖVE package file (works on any platform with LÖVE installed)
- Platform-specific executables (macOS, Windows, Linux) based on your current platform

### Customization

Edit `build.sh` to customize:
- `GAME_NAME` - Name of your game
- `VERSION` - Version number
- `AUTHOR` - Your name/team name

### Distribution

You can distribute:
- The `.love` file (requires LÖVE to be installed)
- Platform-specific executables (standalone, no LÖVE required)

Popular distribution platforms:
- [itch.io](https://itch.io) - Great for indie games
- [Steam](https://steamworks.github.io) - For commercial releases
- Your own website

## Development

Make sure to set `DEBUG = false` and `isDev = false` in `conf.lua` for production builds.

## Documentation

This project includes comprehensive documentation for developers and level designers:

### 📚 Interactive Web Documentation

**Run the documentation viewer:**

From the project root:
```bash
./docs-viewer/serve.sh
```

Or manually:
```bash
# From project root (important!)
python3 -m http.server 8000
```

Then open **http://localhost:8000/docs-viewer/** in your browser.

**Note:** The server must run from the project root, not from `docs-viewer/`.

The interactive viewer includes:
- Search functionality
- Code highlighting
- Dark/light theme
- Table of contents
- Mobile-responsive design

### 📖 Documentation Structure

#### Guides (`docs/guides/`)
- **[Getting Started](docs/guides/getting-started.md)** - Quick start guide
- **[Tiled Integration](docs/guides/tiled-integration.md)** - Complete guide for creating levels in Tiled Map Editor
- **[Trigger System](docs/guides/trigger-system.md)** - Comprehensive trigger system guide
- **[Camera Guide](docs/guides/camera-guide.md)** - Camera usage and examples

#### API Reference (`docs/api/`)
- **Core**: [Camera](docs/api/core/camera.md), [Constants](docs/api/core/constants.md), [Colors](docs/api/core/colors.md), [Utils](docs/api/core/utils.md)
- **Objects**: [Trigger](docs/api/objects/trigger.md), [Player](docs/api/objects/player.md), [Box](docs/api/objects/box.md), [Coin](docs/api/objects/coin.md), [Door](docs/api/objects/door.md), [Teleporter](docs/api/objects/teleporter.md), [Saw](docs/api/objects/saw.md), [Cutscene](docs/api/objects/cutscene.md)
- **States**: [State Machine](docs/api/states/stateMachine.md), [Game State](docs/api/states/game.md)
- **Systems**: [Particles](docs/api/systems/particles.md), [Shaders](docs/api/systems/shaders.md), [Scene Effects](docs/api/systems/sceneEffects.md), [Save System](docs/api/systems/saveSystem.md), [Input Config](docs/api/systems/inputConfig.md)
- **Game**: [Load Map](docs/api/game/loadMap.md), [Resources](docs/api/game/resources.md)
- **Main**: [Main](docs/api/main.md), [Config](docs/api/conf.md)

#### Architecture (`docs/architecture/`)
- **[Project Structure](docs/architecture/project-structure.md)** - Folder organization and structure

#### Examples (`examples/`)
- **[Triggers](examples/triggers/)** - Trigger examples (moving platforms, scaling, sequences)
- **[Camera](examples/camera/)** - Camera examples (following, shake, smooth movement)
- More examples coming soon for particles, states, objects, and systems

### Quick Start for Level Designers

1. Read [Getting Started Guide](docs/guides/getting-started.md)
2. Read [Tiled Integration Guide](docs/guides/tiled-integration.md) for level creation
3. Check [Trigger Examples](examples/triggers/) for common patterns
4. Use triggers to create moving platforms, scaling objects, and sequences

### Quick Start for Developers

1. Read [Getting Started Guide](docs/guides/getting-started.md)
2. Explore [API Reference](docs/api/) for system details
3. Check [Examples](examples/) for code samples
4. Read [Architecture Docs](docs/architecture/) for system design
5. Use the [Interactive Documentation Viewer](docs-viewer/index.html) for the best experience

