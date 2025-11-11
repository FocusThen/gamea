# Architecture Overview

This document highlights the key runtime systems after the readability refactor.

## Core Utilities
- `src/core/utils/` exposes namespaced helpers. Require `src.core.utils` to access:
  - `Utils.deepCopy` for cloning tables.
  - `Utils.countLevels` for enumerating Tiled level exports.
- `src/core/color.lua` centralises hexadecimal parsing:
  - Use `Color.fromHex("#AARRGGBB")` to convert Tiled colour strings to RGBA tables.

## Level Loading Pipeline
1. `src/game/loadMap.lua` is a thin shim that re-exports `src.game.level.loader`.
2. `src/game/level/loader.lua` orchestrates the process:
   - resets the bump world,
   - loads the Tiled map via `level/tiled.lua`,
   - builds entity tables through `level/entities.lua`,
   - parses map metadata in `level/properties.lua`.
3. Entities are assembled with explicit helpers:
   - One-way platforms reuse the shared bump response.
   - Triggers/teleporters resolve their targets after all entities have been registered.
   - A resource-only kill zone protects the map bounds.

## Resource Management
- `src/game/resources/init.lua` exposes `ResourceManager.new()`.
  - Instantiation happens in `love.load`, assigning `_G.resourceManager`.
  - Backwards compatibility is preserved by mirroring `sprites`, `fonts`, `sounds`, `music`, and `playSound` onto `_G`.
  - Prefer the new API where possible: `resourceManager:play("select")` or `resourceManager:playEntry(sounds.select)`.
- Systems that need sprite atlases (e.g. particle effects) derive them from the manager when present.

## States & Systems
- UI-centric states (`main_menu`, `pause`, `levelSelect`) now funnel menu sound effects through helpers that favour `resourceManager`.
- `sceneEffects` caches wipe/fade colours and guards against duplicate transitions.
- `shaders` loads shader programs via a single helper and clamps intensity values with `clamp01`.

## Compatibility Notes
- `player.lua` remains untouched as requested and continues to use the global `playSound`. The compatibility layer keeps this working while newer modules adopt the explicit resource manager.
- When adding new assets, update `ResourceManager` loaders; the globals mirror automatically when `love.load` runs.

