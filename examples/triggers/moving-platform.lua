--[[
    Moving Platform Example
    
    This example demonstrates how to create a moving platform using triggers.
    The platform moves back and forth continuously.
    
    Usage:
    1. Create a box or platform object in Tiled
    2. Create a trigger in Tiled with these properties:
       - action: "sequence"
       - targetId: [ID of the box/platform]
       - once: false (allows repeating)
       - sequence: See below
]]

-- In Tiled, set the trigger's sequence property to:
-- Note: This is a JSON representation for Tiled's custom properties
-- In Tiled, you'll need to set this as a custom property of type "string" or use Tiled's object properties

-- Sequence configuration (for reference):
local sequence = {
    { action = "move", moveX = 200, duration = 2.0 },  -- Move right 200px over 2 seconds
    { action = "wait", delay = 1.0 },                  -- Wait 1 second
    { action = "move", moveX = -200, duration = 2.0 }, -- Move left 200px over 2 seconds
    { action = "wait", delay = 1.0 }                   -- Wait 1 second, then repeat
}

-- Alternative: Using speed instead of duration
local sequenceWithSpeed = {
    { action = "move", moveX = 200, speed = 100 },  -- Move at 100 pixels/second
    { action = "wait", delay = 1.0 },
    { action = "move", moveX = -200, speed = 100 },
    { action = "wait", delay = 1.0 }
}

--[[
    Tiled Setup Instructions:
    
    1. Create a box object in the "Spawns" layer
       - Name: "box"
       - Note the object ID (shown in properties panel)
    
    2. Create a trigger rectangle in the "Spawns" layer
       - Name: "trigger"
       - Properties:
         * action: "sequence"
         * targetId: [the box's ID]
         * once: false
         * sequence: [see sequence table above]
    
    3. The trigger will activate when player touches it
       - Platform starts moving
       - Repeats indefinitely (once = false)
]]

