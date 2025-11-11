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

- `action` (string, optional): Action type - "move", "wait", "activate", "sequence", "cutscene", "timer" (default: "move")
- `targetId` (number or object reference): ID of the target object to affect
- `moveX` (number, optional): X distance to move target (pixels)
- `moveY` (number, optional): Y distance to move target (pixels)
- `speed` (number, optional): Movement speed in pixels per second (overrides duration)
- `duration` (number, optional): Movement duration in seconds (default: 0.5, used if speed not set)
- `once` (boolean, optional): Whether trigger can only activate once (default: true)
- `delay` (number, optional): Delay before action starts (seconds, default: 0)
- `timerDelay` (number, optional): For timer-based triggers, delay before activation (seconds)

**Action Types:**

- `move`: Move target object smoothly (requires targetId, moveX, moveY)
- `wait`: Wait for a duration (used in sequences)
- `activate`: Activate another trigger/object
- `sequence`: Execute a sequence of actions (requires sequence property as array)
- `cutscene`: Trigger a cutscene (requires cutscene property)
- `timer`: Automatically activate after timerDelay seconds

**Trigger Action Examples:**

- `move`

  - `targetId`: 12
  - `moveX`: 64
  - `moveY`: -32
  - `speed`: 80
  - Use case: slide a platform right and slightly upward when the player overlaps the trigger.

- `wait`

  - `duration`: 1.5
  - Use case: pause a moving platform mid-sequence for dramatic timing.

- `activate`

  - `targetId`: 27
  - `once`: false
  - Use case: toggle another trigger repeatedly (e.g., start and stop a saw).

- `sequence`

  - `sequence`: `[ { action = "move", targetId = 40, moveX = 96, speed = 60 }, { action = "wait", duration = 0.75 }, { action = "move", targetId = 40, moveX = -96, speed = 60 } ]`
  - Use case: move a platform out and back with a brief pause.

- `cutscene`

  - `cutscene`: `"intro_bridge"`
  - `delay`: 0.5
  - Use case: start a scripted camera pan shortly after the trigger fires.

- `timer`
  - `timerDelay`: 3
  - `targetId`: 55
  - `action`: `"activate"`
  - Use case: launch a delayed chain reaction without player interaction.

**Example:**

- Create a rectangle object in "Spawns" layer
- Set name to `trigger`
- Set `targetId` to the ID of another object (e.g., a coin)
- Set `moveX` to 100 to move target 100 pixels right
- Set `speed` to 50 for smooth movement at 50 px/s

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

- `targetId` can reference any object; the teleporter will drop the player at that object's position
- Teleporters can still work in pairs by pointing to another teleporter object
- Player teleports to the center of the target object (or the top of a teleporter)
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
- **Teleporter not working**: Verify both teleporters have correct `targetId` references
