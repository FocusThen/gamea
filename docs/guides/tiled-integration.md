# Tiled Map Editor Guide

This guide explains how to create objects in Tiled Map Editor for use in this Love2D platformer template.

## Layer Structure

The game expects the following layers in your Tiled map:

### Required Layers

1. **Platforms** (Object Layer)

   - Contains collision platforms for the game world
   - Objects in this layer are collision-only (not drawn)

2. **Spawns** (Object Layer)

   - Contains all spawnable game objects (player, coins, boxes, doors, triggers, teleporters)

3. **Dangers** (Object Layer)
   - Contains dangerous objects (spikes, saws, deadlyObjects)

### Optional Layers

- **Bg** (Tile Layer)
  - Background tiles that are drawn behind all game objects

## Object Types

### Player

**Layer:** Spawns  
**Name:** `player`  
**Properties:**

- `doubleJump` (boolean, optional): Whether player has double jump ability
- `dash` (boolean, optional): Whether player has dash ability

**Example:**

- Create a rectangle object in the "Spawns" layer
- Set the name to `player`
- Add custom properties as needed

### Coin (Pickup)

**Layer:** Spawns  
**Name:** `coin`  
**Properties:** None required

**Notes:**

- Coins are automatically collected when player touches them
- They are removed from the world after collection

### Box

**Layer:** Spawns  
**Name:** `box`  
**Properties:** None required

**Notes:**

- Boxes can be pushed by the player
- They are affected by gravity and physics

### Door

**Layer:** Spawns  
**Name:** `door`  
**Properties:** None required

**Notes:**

- When player touches a door, they advance to the next level
- If it's the last level, player goes to the ending screen

### Trigger

**Layer:** Spawns  
**Name:** `trigger`  
**Properties:**

- `action` (string, optional): Action type - "move", "scale", "wait", "activate", "sequence", "cutscene", "timer" (default: "move")
- `targetId` (number or object reference): ID of the target object to affect
- `moveX` (number, optional): X distance to move target (pixels)
- `moveY` (number, optional): Y distance to move target (pixels)
- `speed` (number, optional): Movement speed in pixels per second (overrides duration)
- `duration` (number, optional): Movement/scale duration in seconds (default: 0.5, used if speed not set)
- `once` (boolean, optional): Whether trigger can only activate once (default: true)
- `delay` (number, optional): Delay before action starts (seconds, default: 0)
- `timerDelay` (number, optional): For timer-based triggers, delay before activation (seconds)

**Scaling Properties (for `action = "scale"`):**

- `scale` (number, optional): Uniform scale target (e.g., 0.5 = half size, 2.0 = double size)
- `scaleX` (number, optional): Relative X scale change (e.g., 0.5 = shrink width by 50%)
- `scaleY` (number, optional): Relative Y scale change (e.g., 2.0 = double height)
- `startScale` (number, optional): Starting uniform scale (defaults to current scale or 1.0)
- `startScaleX` (number, optional): Starting X scale
- `startScaleY` (number, optional): Starting Y scale
- `endScale` (number, optional): Ending uniform scale (absolute value)
- `endScaleX` (number, optional): Ending X scale (absolute value)
- `endScaleY` (number, optional): Ending Y scale (absolute value)

**Action Types:**

- `move`: Move target object smoothly (requires targetId, moveX, moveY)
- `scale`: Scale target object smoothly (requires targetId, and scale properties)
- `wait`: Wait for a duration (used in sequences)
- `activate`: Activate another trigger/object
- `sequence`: Execute a sequence of actions (requires sequence property as array)
- `cutscene`: Trigger a cutscene (requires cutscene property)
- `timer`: Automatically activate after timerDelay seconds

**Trigger Examples:**

**Moving a Box:**
- Create a rectangle object in "Spawns" layer
- Set name to `trigger`
- Set `action` to `move`
- Set `targetId` to the ID of a box
- Set `moveX` to 100 to move target 100 pixels right
- Set `speed` to 50 for smooth movement at 50 px/s

**Shrinking a Coin:**
- Create a rectangle object in "Spawns" layer
- Set name to `trigger`
- Set `action` to `scale`
- Set `targetId` to the ID of a coin
- Set `scale` to 0.5 to shrink to half size
- Set `duration` to 1.0 for a 1-second animation

**Growing a Box:**
- Set `action` to `scale`
- Set `targetId` to box ID
- Set `scale` to 2.0 to double the size
- Set `duration` to 1.5 for a 1.5-second animation

**Stretching Horizontally:**
- Set `action` to `scale`
- Set `targetId` to target object ID
- Set `scaleX` to 2.0 to double width (height stays same)
- Set `duration` to 1.0

**Scaling from Specific Values:**
- Set `action` to `scale`
- Set `startScale` to 1.0
- Set `endScale` to 0.3
- Set `duration` to 2.0

### Teleporter

**Layer:** Spawns  
**Name:** `teleporter`  
**Properties:**

- `targetId` (number or object reference): ID of destination teleporter
- `targetX` (number, optional): Alternative - X coordinate destination
- `targetY` (number, optional): Alternative - Y coordinate destination
- `cooldown` (number, optional): Time before can teleport again (seconds, default: 0.5)
- `transitionDuration` (number, optional): Fade transition duration (seconds, default: 0.3)

**Notes:**

- Teleporters work in pairs - link them using `targetId`
- Player teleports to the center of the target teleporter
- Has a cooldown to prevent rapid teleportation

### Spike

**Layer:** Dangers  
**Name:** `spike`  
**Properties:** None required

**Notes:**

- Kills player on contact
- No special properties needed

### Deadly Object

**Layer:** Dangers  
**Name:** `deadlyObject`  
**Properties:** None required

**Notes:**

- Kills player on contact (same behavior as spikes)
- **Invisible by default** - perfect for trick traps
- Can be placed over coins to create "fake coins" that kill the player
- Can be placed anywhere as an invisible hazard
- Useful for creating tricky platforming challenges where players need to identify safe vs unsafe areas

**Example Usage:**

- Place a `deadlyObject` directly over a coin to create a fake coin trap
- Place multiple `deadlyObject` rectangles in a pattern to create an invisible hazard zone
- Combine with visible coins to create a mix of safe and dangerous pickups

### Saw

**Layer:** Dangers  
**Name:** `saw`  
**Properties:**

- `direction` (string, optional): "horizontal" or "vertical" (default: "horizontal")
- `distance` (number, optional): Movement distance in pixels (default: 100)
- `speed` (number, optional): Movement speed in pixels per second (default: 50)

**Notes:**

- Saws move back and forth continuously
- Kills player on contact
- Direction determines if saw moves left/right or up/down

## Object IDs

**Important:** All objects that can be referenced by other objects (triggers, teleporters) must have unique IDs. In Tiled:

1. Select an object
2. In the Properties panel, the object ID is shown at the top
3. Use this ID in `targetId` properties

## Object References in Tiled

When setting `targetId` in Tiled:

- You can use the object reference type and select the target object
- Tiled will save it as `{id = X}` format
- The game automatically converts this to the numeric ID

## Platform Objects

**Layer:** Platforms  
**Name:** Any (or no name)  
**Properties:** None

**Notes:**

- Platforms are collision-only (not drawn)
- They block player and box movement
- Use rectangles for platforms

## Best Practices

1. **Unique IDs**: Ensure all objects that need to be referenced have unique IDs
2. **Layer Names**: Use exact layer names ("Platforms", "Spawns", "Dangers", "Bg")
3. **Object Names**: Use exact object names (case-sensitive: "player", "coin", "trigger", etc.)
4. **Properties**: Always set properties in Tiled's Custom Properties panel
5. **Testing**: Test trigger linking in-game to ensure targetId references work correctly

## Example Workflow

1. Create a new map in Tiled
2. Create layers: "Platforms", "Spawns", "Dangers", "Bg"
3. Draw platforms in the "Platforms" layer
4. Place spawn objects in the "Spawns" layer with correct names
5. Place danger objects in the "Dangers" layer
6. Set object properties as needed
7. Export map as Lua format (File > Export As > Lua file)
8. Save the `.lua` file in the `maps/` directory
9. The game will automatically load objects from the map

## Troubleshooting

- **Trigger not activating**: Check that `targetId` matches an object ID in the map
- **Object not appearing**: Verify layer name and object name are correct
- **Movement not working**: Ensure `moveX` or `moveY` is set, and `targetId` is correct
- **Scaling not working**: Ensure `scale`, `scaleX`, `scaleY`, or `endScale` properties are set, and `targetId` is correct
- **Teleporter not working**: Verify both teleporters have correct `targetId` references
