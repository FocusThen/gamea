--[[
    Camera Following Player Example
    
    This example shows how to make the camera follow the player smoothly.
]]

-- In game state update:
function gameScene:update(dt)
    -- Update camera to follow player center
    local centerX = player.x + player.width / 2
    local centerY = player.y + player.height / 2
    camera:setTarget(centerX, centerY)
    camera:update(dt)
    
    -- Update other game objects
    -- ...
end

-- In game state draw:
function gameScene:draw()
    -- Apply camera transform
    camera:apply()
    
    -- Draw game world (affected by camera)
    drawMap()
    drawObjects()
    player:draw()
    
    -- Remove camera transform
    camera:unapply()
    
    -- Draw UI (not affected by camera)
    drawUI()
end

--[[
    Smooth Following (Enhanced)
    
    For smoother camera movement, modify camera:update():
]]

function camera:update(dt)
    -- Smooth following with lerp
    local lerpSpeed = 5.0
    self.x = self.x + (self.targetX - self.x) * lerpSpeed * dt
    self.y = self.y + (self.targetY - self.y) * lerpSpeed * dt
    
    -- Update shake (existing code)
    if self.shakeTimer > 0 then
        self.shakeTimer = self.shakeTimer - dt
        local shakeAmount = (self.shakeTimer / self.shakeDuration) * self.shakeIntensity
        self.shakeX = (math.random() - 0.5) * shakeAmount * 2
        self.shakeY = (math.random() - 0.5) * shakeAmount * 2
        
        if self.shakeTimer <= 0 then
            self.shakeTimer = 0
            self.shakeIntensity = 0
            self.shakeX = 0
            self.shakeY = 0
        end
    else
        self.shakeX = 0
        self.shakeY = 0
    end
end

