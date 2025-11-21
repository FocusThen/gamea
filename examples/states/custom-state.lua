--[[
    Custom State Example
    
    This example shows how to create a new game state.
]]

local MyCustomState = Object:extend()

function MyCustomState:new()
    -- Initialize state
    self.bindings = require("src.systems.inputConfig").createMenuBindings()
end

function MyCustomState:enter(params)
    -- Called when entering this state
    -- params can contain data passed from setState()
    if params then
        -- Use params
    end
end

function MyCustomState:exit()
    -- Called when leaving this state
    -- Cleanup if needed
end

function MyCustomState:update(dt)
    -- Update state logic
    self.bindings:update()
    
    if self.bindings:pressed("select") then
        -- Handle input
    end
end

function MyCustomState:draw()
    -- Draw state
    love.graphics.print("My Custom State", 100, 100)
end

function MyCustomState:keypressed(key)
    -- Handle key presses
end

function MyCustomState:keyreleased(key)
    -- Handle key releases
end

return MyCustomState

--[[
    To use this state:
    
    1. Save as src/states/myCustomState.lua
    2. Add to stateMachine:loadStates():
       self.states.myCustom = require("src.states.myCustomState")()
    3. Switch to it:
       stateMachine:setState("myCustom", { optionalParams })
]]

