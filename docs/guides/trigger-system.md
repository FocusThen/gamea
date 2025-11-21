# Trigger System Developer Guide

This document provides a comprehensive guide to the trigger system implementation, designed for developers who want to understand, extend, or learn from this codebase.

## Overview

The trigger system is a flexible, event-driven mechanism that allows game objects to interact with each other. Triggers can move, scale, activate, and sequence actions on target entities when activated by the player or automatically via timers.

## Architecture

### Core Components

1. **Trigger Object** (`src/objects/trigger.lua`)
   - Main trigger implementation
   - Handles all action types and state management
   - Uses flux library for smooth tweening

2. **Action Types**
   - `move`: Smoothly move target entities
   - `scale`: Smoothly scale target entities
   - `activate`: Activate other triggers/objects
   - `sequence`: Execute multiple actions in order
   - `cutscene`: Trigger cutscene sequences
   - `timer`: Auto-activate after delay
   - `wait`: Wait for duration (used in sequences)

3. **Integration Points**
   - Map loading (`src/game/loadMap.lua`): Links triggers to targets via `targetId`
   - Player interaction (`src/objects/player.lua`): Player collision activates triggers
   - Game state (`src/states/game.lua`): Updates triggers each frame

## Implementation Details

### Trigger Initialization

```lua
function trigger:new(x, y, width, height, props)
```

**Parameters:**
- `x, y`: Position in world coordinates
- `width, height`: Trigger collision area
- `props`: Properties from Tiled map (action, targetId, moveX, etc.)

**Key Properties:**
- `action`: Type of action to perform
- `targetId`: ID of target object (linked during map load)
- `once`: Whether trigger can only activate once
- `delay`: Delay before action starts
- `duration`: Duration of movement/scaling animation

### Movement System

**How it works:**
1. Player collides with trigger → `interact()` called
2. `activate()` checks if trigger can activate
3. `doMove()` calculates start/end positions
4. Creates flux tween to animate `moveProgress` from 0 to 1
5. `updateMovingTarget()` called each frame to update position
6. Physics world updated continuously for collision detection

**Key Methods:**
- `doMove()`: Sets up movement tween
- `updateMovingTarget()`: Updates target position based on progress
- Handles "riders" (player/boxes on moving platforms)

**Example:**
```lua
-- Move box 100 pixels right over 2 seconds
trigger.action = "move"
trigger.targetId = boxId
trigger.moveX = 100
trigger.duration = 2.0
```

### Scaling System

**How it works:**
1. Similar to movement, but modifies entity dimensions
2. Stores original width/height on first activation
3. Calculates current scale based on progress (0 to 1)
4. Updates entity width/height proportionally
5. Maintains center point during scaling (position adjusts)
6. Updates physics world with new dimensions

**Key Methods:**
- `doScale()`: Sets up scaling tween and calculates scale values
- `updateScalingTarget()`: Updates target dimensions and position

**Scale Calculation Priority:**
1. `endScaleX/Y` (absolute target values)
2. `scaleX/Y` (relative changes from current)
3. `endScale` (uniform absolute target)
4. `scale` (uniform relative change)

**Example:**
```lua
-- Shrink box to half size over 1 second
trigger.action = "scale"
trigger.targetId = boxId
trigger.scale = 0.5
trigger.duration = 1.0
```

**Scaling Behavior:**
- Entities scale from their center point
- Original dimensions stored on first activation
- If entity already scaled, calculates base size
- Physics world updated with new dimensions
- Collision detection works correctly during scaling

### Sequence System

Sequences allow chaining multiple actions together:

```lua
trigger.action = "sequence"
trigger.sequence = {
    { action = "move", moveX = 100, duration = 1.0 },
    { action = "wait", delay = 0.5 },
    { action = "scale", scale = 0.5, duration = 1.0 },
    { action = "activate", targetId = otherTriggerId }
}
```

**How it works:**
1. `doSequence()` starts sequence execution
2. `executeSequenceStep()` processes each step
3. After each action completes, waits for delay
4. Moves to next step in sequence
5. Continues until all steps complete

### Activation System

**Activation Methods:**
1. **Player Collision**: Player touches trigger → `interact()` → `activate()`
2. **Timer**: Auto-activates after `timerDelay` seconds
3. **Other Trigger**: Trigger with `action = "activate"` can activate another

**Activation Flow:**
```
Player Collision
    ↓
trigger:interact(player)
    ↓
trigger:activate()
    ↓
Check delay → Execute action
```

### Physics Integration

**Bump Physics World:**
- Triggers added as non-collidable (`cross` response)
- Target entities updated via `World:update(item, x, y, w, h)`
- Movement: Updates position continuously
- Scaling: Updates position AND dimensions continuously

**Rider System:**
- Moving platforms push players/boxes on top
- Uses `World:queryRect()` to find entities on platform
- Applies platform movement to riders
- Handles vertical movement (prevents player falling through)

## Extending the System

### Adding New Action Types

1. **Add action to constructor:**
```lua
-- In trigger:new()
self.action = props and (props.action or "move") or "move"
-- Add your new action to the comment
```

2. **Add handler in activate():**
```lua
-- In trigger:activate()
elseif self.action == "yourAction" then
    self:doYourAction()
```

3. **Implement action method:**
```lua
function trigger:doYourAction()
    -- Your implementation
    if self.target then
        -- Do something to self.target
    end
end
```

4. **Add to delay handler:**
```lua
-- In trigger:update() delay handler
elseif self.action == "yourAction" then
    self:doYourAction()
```

5. **Add to sequence support (optional):**
```lua
-- In trigger:executeSequenceStep()
elseif stepAction == "yourAction" then
    -- Handle sequence step
```

### Example: Rotate Action

```lua
-- In trigger:new(), add rotation properties
self.rotateAngle = props and props.rotateAngle or 0
self.startAngle = nil
self.endAngle = nil
self.isRotating = false
self.rotationProgress = 0
self.rotationTween = nil

-- In trigger:activate()
elseif self.action == "rotate" then
    self:doRotate()

-- Implement doRotate()
function trigger:doRotate()
    if not self.target then return end
    
    self.startAngle = self.target.angle or 0
    self.endAngle = self.startAngle + self.rotateAngle
    
    local rotationDuration = self.duration or 0.5
    self.isRotating = true
    self.rotationProgress = 0
    
    self.rotationTween = flux.to(self, rotationDuration, { rotationProgress = 1 })
        :oncomplete(function()
            self.isRotating = false
            self.rotationTween = nil
            self.rotationProgress = 1
            self:updateRotatingTarget(true)
        end)
    self:updateRotatingTarget(true)
end

-- Implement updateRotatingTarget()
function trigger:updateRotatingTarget(force)
    if not self.target then return end
    
    local currentAngle = self.startAngle + 
        (self.endAngle - self.startAngle) * self.rotationProgress
    
    self.target.angle = currentAngle
    -- Update physics if needed
end

-- In trigger:update()
if self.isRotating then
    self:updateRotatingTarget()
end
```

## Best Practices

### Performance

1. **Limit Active Triggers**: Only triggers with active tweens update each frame
2. **Use `once = true`**: Prevents unnecessary re-activation checks
3. **Reasonable Durations**: Very short durations (< 0.1s) may cause jitter

### Physics

1. **Always Update World**: Use `World:update()` when changing position/size
2. **Handle Riders**: Moving platforms should push entities on top
3. **Center Scaling**: Scaling from center maintains visual consistency

### Design

1. **Clear Target IDs**: Use descriptive names/notes in Tiled for target objects
2. **Test Sequences**: Complex sequences should be tested thoroughly
3. **Duration Consistency**: Use similar durations for related actions

## Common Patterns

### Moving Platform

```lua
-- Trigger that moves a platform back and forth
trigger.action = "sequence"
trigger.sequence = {
    { action = "move", moveX = 200, duration = 2.0 },
    { action = "wait", delay = 1.0 },
    { action = "move", moveX = -200, duration = 2.0 },
    { action = "wait", delay = 1.0 }
}
trigger.once = false  -- Allow repeating
```

### Shrinking Door

```lua
-- Door that shrinks when player approaches
trigger.action = "scale"
trigger.targetId = doorId
trigger.scale = 0.0  -- Shrink to nothing
trigger.duration = 1.0
trigger.once = true
```

### Chain Reaction

```lua
-- Trigger 1 activates Trigger 2, which activates Trigger 3
trigger1.action = "activate"
trigger1.targetId = trigger2Id

trigger2.action = "activate"
trigger2.targetId = trigger3Id
trigger2.delay = 0.5  -- Small delay for effect
```

### Combined Move and Scale

```lua
-- Move and scale simultaneously using sequence
trigger.action = "sequence"
trigger.sequence = {
    { action = "move", moveX = 100, duration = 1.0 },
    { action = "scale", scale = 0.5, duration = 1.0 }
}
-- Note: These run sequentially. For simultaneous, you'd need to extend the system.
```

## Troubleshooting

### Trigger Not Activating

- Check `targetId` matches object ID in map
- Verify trigger is in "Spawns" layer
- Check `once` property (may already be activated)
- Ensure player is actually colliding with trigger

### Movement Issues

- Verify `moveX`/`moveY` are set
- Check `duration` or `speed` is set
- Ensure target object exists and has position

### Scaling Issues

- Verify scale properties are set (`scale`, `scaleX`, `scaleY`, or `endScale`)
- Check target has `width` and `height` properties
- Ensure `duration` is set
- Physics world should update automatically

### Sequence Problems

- Verify `sequence` is an array/table
- Check each step has `action` property
- Ensure delays are reasonable
- Test each step individually first

## Code Structure Reference

### Key Variables

**State:**
- `isMoving`: Whether movement tween is active
- `isScaling`: Whether scaling tween is active
- `moveProgress`: Movement progress (0 to 1)
- `scaleProgress`: Scaling progress (0 to 1)

**Position:**
- `startX/Y`: Starting position for movement
- `endX/Y`: Ending position for movement
- `lastTargetX/Y`: Last known target position

**Scaling:**
- `originalWidth/Height`: Base dimensions before scaling
- `currentScaleX/Y`: Current scale values
- `targetScaleX/Y`: Target scale values

**Tweening:**
- `moveTween`: Flux tween for movement
- `scaleTween`: Flux tween for scaling

### Key Methods

**Activation:**
- `activate()`: Main activation entry point
- `interact(player)`: Called when player collides

**Actions:**
- `doMove()`: Set up movement
- `doScale()`: Set up scaling
- `doActivate()`: Activate target
- `doSequence()`: Start sequence
- `doCutscene()`: Start cutscene

**Updates:**
- `updateMovingTarget()`: Update position during movement
- `updateScalingTarget()`: Update size during scaling
- `executeSequenceStep()`: Process sequence step

## Dependencies

- **flux**: Smooth tweening library (`lib/flux/flux.lua`)
- **bump**: Physics collision library (`lib/bump/bump.lua`)
- **classic**: OOP library (`lib/classic/classic.lua`)

## Future Enhancements

Potential improvements for the trigger system:

1. **Simultaneous Actions**: Allow move + scale at same time
2. **Easing Functions**: Add different easing types (ease-in, ease-out, bounce)
3. **Path Following**: Move along bezier curves or paths
4. **Rotation**: Add rotation action type
5. **Color Tinting**: Fade colors during transitions
6. **Sound Triggers**: Play sounds on activation
7. **Conditional Actions**: Only activate if conditions met
8. **Trigger Groups**: Activate multiple targets at once

## License

This trigger system is part of the game template. See project license for details.

