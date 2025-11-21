--[[
    Jump Particle Effect Example
    
    This example shows how to create a jump particle effect when the player jumps.
]]

-- In player:doJump()
function player:doJump()
    -- Create jump effect at player's feet
    particleEffects:createEffect("jump", 
        self.x + self.width / 2 - 10,  -- Center X position
        self.y + self.height - 6        -- Bottom of player
    )
    
    self.yVel = self.jump
    self.coyote = 0
end

--[[
    Available Particle Effects:
    
    - "jump" - Jump smoke (7 frames)
    - "dash" - Dash smoke (6 frames)
    - "landing" - Landing smoke (4 frames)
    - "boxLanding" - Box landing effect (4 frames)
    - "walk" - Walking effect (6 frames)
    
    Usage:
    particleEffects:createEffect(effectName, x, y, flip)
    
    Parameters:
    - effectName: String name of effect
    - x, y: Position coordinates
    - flip: Optional boolean to flip horizontally
]]

