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

