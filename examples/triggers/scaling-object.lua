--[[
    Scaling Object Example
    
    This example demonstrates how to scale entities using triggers.
    The object shrinks or grows smoothly.
    
    Usage:
    1. Create a box or other object in Tiled
    2. Create a trigger with scale properties
]]

-- Example 1: Shrink to half size
-- Trigger properties:
--   action: "scale"
--   targetId: [object ID]
--   scale: 0.5
--   duration: 1.0

-- Example 2: Grow to double size
-- Trigger properties:
--   action: "scale"
--   targetId: [object ID]
--   scale: 2.0
--   duration: 1.5

-- Example 3: Scale only width (stretch horizontally)
-- Trigger properties:
--   action: "scale"
--   targetId: [object ID]
--   scaleX: 2.0  (doubles width)
--   duration: 1.0

-- Example 4: Scale from specific start to end
-- Trigger properties:
--   action: "scale"
--   targetId: [object ID]
--   startScale: 1.0
--   endScale: 0.3
--   duration: 2.0

-- Example 5: Scale relative to current size
-- Trigger properties:
--   action: "scale"
--   targetId: [object ID]
--   scale: -0.5  (shrink by 50% from current)
--   duration: 1.0

--[[
    Tiled Setup Instructions:
    
    1. Create an object (box, coin, etc.) in "Spawns" layer
       - Note the object ID
    
    2. Create a trigger in "Spawns" layer
       - Name: "trigger"
       - Properties:
         * action: "scale"
         * targetId: [object ID]
         * scale: 0.5 (or scaleX, scaleY, endScale, etc.)
         * duration: 1.0
    
    3. When player touches trigger, object scales smoothly
       - Scales from center point
       - Physics world updates automatically
       - Collision detection works during scaling
]]

