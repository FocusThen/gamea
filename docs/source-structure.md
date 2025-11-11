# Source Structure Refresh

This document captures the target layout and role of each module slated for the readability refactor.

## Core Layer (`src/core`)

- `constants.lua` — shared numeric/string constants (unchanged).
- `camera.lua` — camera helper class (unchanged).
- `utils/init.lua` — utility entry point returning a table of helpers (new module replaces global `require` side effects).
  - `utils/table.lua` — table helpers (e.g. `deepCopy`).
  - `utils/fs.lua` — filesystem-oriented helpers (e.g. `countLevels`).
- `color.lua` — colour parsing/formatting helpers (new; provides `fromHex`, `toHex`).

## Game-Level Modules (`src/game`)

- `game/init.lua` — orchestrates high-level game lifecycle helpers (lightweight aggregator).
- `game/resources/init.lua` — exposes `load()` returning structured assets (`sprites`, `fonts`, `sounds`, `music`) instead of mutating globals.
- `game/level/loader.lua` — entry point used by states to load levels.
  - `level/tiled.lua` — wraps STI initialisation.
  - `level/entities.lua` — builds entity tables, handles trigger/teleporter linking.
  - `level/properties.lua` — extracts level metadata (e.g. colours) via `core.color`.

## Systems (`src/systems`)

- Continue to expose explicit constructors (e.g. `sceneEffects.new(canvas)`), no global singletons.
- Shared shader utilities to use `core.color` where needed.

## States (`src/states`)

- Update to consume the refactored modules:
  - Require `src.game.level.loader`.
  - Obtain assets via `resources:load()` injected from `main.lua`.
  - Avoid reliance on global `World`, `particleEffects`, etc. Use explicit dependencies where feasible.

## Objects (`src/objects`)

- Keep existing hierarchy, but adjust requires to use new module exports.
- `player.lua` remains untouched per instruction; other objects switch to the new dependency style (e.g. pulling constants via `require("src.core.constants")`).

## Application Entry (`main.lua`)

- Replace implicit globals with locals set up at load time.
- Instantiate systems/resources via new modules and pass references through the state machine.

## Supporting Files

- Add a `docs/` directory (this file) for future architecture notes.

This structure underpins subsequent tasks:

1. Convert helper scripts to module-return style.
2. Break up the map loader into focused files.
3. Standardise naming/formatting across states and systems.
4. Simplify resource loading API and cascade updates.
