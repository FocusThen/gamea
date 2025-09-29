-- ===================================
-- USAGE EXAMPLES AND CONFIGURATION
-- ===================================

--[[
FOLDER STRUCTURE:
src/
├── core/
│   ├── GameStateManager.lua
│   ├── EntityManager.lua
│   └── AssetManager.lua
├── states/
│   ├── MenuState.lua
│   ├── GameState.lua
│   ├── PauseState.lua
│   └── GameOverState.lua
├── entities/
│   ├── BaseEntity.lua
│   ├── Player.lua
│   ├── Enemy.lua
│   ├── Ground.lua
│   ├── Pickup.lua
│   └── Projectile.lua
└── levels/
    ├── Level1.lua
    └── LevelLoader.lua

CREATING CUSTOM ENTITIES:

-- src/entities/MyCustomEntity.lua
local BaseEntity = require("src.entities.BaseEntity")
local MyCustomEntity = BaseEntity:extend()

function MyCustomEntity:new(x, y)
    MyCustomEntity.super.new(self, x, y, 32, 32)
    self.type = "mycustom"
    -- Add custom properties
end

function MyCustomEntity:update(dt)
    -- Custom behavior
    MyCustomEntity.super.update(self, dt)
end

return MyCustomEntity

USING THE SYSTEM:

-- In GameState.lua or anywhere else:
local MyCustomEntity = require("src.entities.MyCustomEntity")

-- Create entity
local entity = MyCustomEntity(100, 200)
EM:addEntity(entity)

-- Query entities
local enemies = EM:getEntitiesByType("enemy")
local players = EM:getEntitiesByType("player")

-- Remove entity
EM:removeEntity(entity)

LIBRARIES INTEGRATION:
- bump: Physics collision detection ✓
- classic: Class system ✓
- anim8: Animation system (ready to use)
- flux: Tweening system ✓
- hump: Vector, Timer, Camera ✓
- sti: Tiled map loader (ready to use)

RECOMMENDED NEXT STEPS:
1. Create your specific entities by extending BaseEntity
2. Add sprite sheets and use anim8 for animations
3. Create levels using STI (Tiled maps)
4. Add sound effects using AssetManager
5. Implement game-specific features (inventory, dialogue, etc.)
--]]
