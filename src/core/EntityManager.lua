local EntityManager = Class:extend()

function EntityManager:new()
	self.entities = {}
	self.entitiesToAdd = {}
	self.entitiesToRemove = {}
	self.entityTypes = {}
end

function EntityManager:addEntity(entity)
	table.insert(self.entitiesToAdd, entity)

	-- Track by type for easy queries
	if not self.entityTypes[entity.type] then
		self.entityTypes[entity.type] = {}
	end
	table.insert(self.entityTypes[entity.type], entity)
end

function EntityManager:removeEntity(entity)
	table.insert(self.entitiesToRemove, entity)
	entity.destroyed = true
end

function EntityManager:getEntitiesByType(entityType)
	return self.entityTypes[entityType] or {}
end

function EntityManager:getEntityCount()
	return #self.entities
end

function EntityManager:update(dt)
	-- Add new entities
	for _, entity in ipairs(self.entitiesToAdd) do
		table.insert(self.entities, entity)
	end
	self.entitiesToAdd = {}

	-- Update all entities
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if entity.update and not entity.destroyed then
			entity:update(dt)
		end

		if entity.destroyed then
			table.insert(self.entitiesToRemove, entity)
		end
	end

	-- Remove destroyed entities
	for _, entityToRemove in ipairs(self.entitiesToRemove) do
		for i = #self.entities, 1, -1 do
			if self.entities[i] == entityToRemove then
				if self.entities[i].destroy then
					self.entities[i]:destroy()
				end
				table.remove(self.entities, i)
				break
			end
		end

		-- Remove from type tracking
		if self.entityTypes[entityToRemove.type] then
			for i = #self.entityTypes[entityToRemove.type], 1, -1 do
				if self.entityTypes[entityToRemove.type][i] == entityToRemove then
					table.remove(self.entityTypes[entityToRemove.type], i)
					break
				end
			end
		end
	end
	self.entitiesToRemove = {}
end

function EntityManager:draw()
	-- Sort entities by z-index before drawing
	local sortedEntities = {}
	for _, entity in ipairs(self.entities) do
		table.insert(sortedEntities, entity)
	end

	table.sort(sortedEntities, function(a, b)
		local zA = a.zIndex or 0
		local zB = b.zIndex or 0
		return zA < zB
	end)

	for _, entity in ipairs(sortedEntities) do
		if entity.draw then
			entity:draw()
		end
	end

	-- Draw collision boxes if debug enabled
	-- if GameConfig and GameConfig.debug.showCollisions then
	-- 	love.graphics.setColor(1, 0, 0, 0.3)
	-- 	for _, entity in ipairs(self.entities) do
	-- 		if entity.x and entity.y and entity.w and entity.h then
	-- 			love.graphics.rectangle("line", entity.x, entity.y, entity.w, entity.h)
	-- 		end
	-- 	end
	-- 	love.graphics.setColor(1, 1, 1)
	-- end
end

function EntityManager:clear()
	for _, entity in ipairs(self.entities) do
		if entity.destroy then
			entity:destroy()
		end
	end
	self.entities = {}
	self.entityTypes = {}
	self.entitiesToAdd = {}
	self.entitiesToRemove = {}
end

return EntityManager
