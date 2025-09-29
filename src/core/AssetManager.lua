local AssetManager = Class:extend()

function AssetManager:new()
	self.textures = {}
	self.sounds = {}
	self.fonts = {}
	self.animations = {}
end

function AssetManager:loadAssets()
	-- Load textures
	self:loadTextures()

	-- Load sounds
	self:loadSounds()

	-- Load fonts
	self:loadFonts()

	-- Create animations
	self:createAnimations()
end

function AssetManager:loadTextures()
	-- Example texture loading
	-- self.textures.player = love.graphics.newImage("assets/images/player.png")
	-- self.textures.enemy = love.graphics.newImage("assets/images/enemy.png")

	-- For now, create placeholder colored rectangles
	local canvas = love.graphics.newCanvas(32, 32)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, 32, 32)
	love.graphics.setCanvas()
	self.textures.player = canvas

	-- Create more placeholder textures as needed
end

function AssetManager:loadSounds()
	-- Example sound loading
	-- self.sounds.jump = love.audio.newSource("assets/sounds/jump.ogg", "static")
	-- self.sounds.music = love.audio.newSource("assets/sounds/music.ogg", "stream")
end

function AssetManager:loadFonts()
	self.fonts.small = love.graphics.newFont(12)
	self.fonts.medium = love.graphics.newFont(18)
	self.fonts.large = love.graphics.newFont(24)
end

function AssetManager:createAnimations()
	-- Example animation creation with anim8
	-- if self.textures.player then
	--     local grid = anim8.newGrid(32, 32, self.textures.player:getWidth(), self.textures.player:getHeight())
	--     self.animations.playerIdle = anim8.newAnimation(grid('1-4', 1), 0.1)
	--     self.animations.playerWalk = anim8.newAnimation(grid('1-8', 2), 0.1)
	-- end
end

function AssetManager:getTexture(name)
	return self.textures[name]
end

function AssetManager:getSound(name)
	return self.sounds[name]
end

function AssetManager:getFont(name)
	return self.fonts[name] or self.fonts.medium
end

function AssetManager:getAnimation(name)
	return self.animations[name]
end

return AssetManager
