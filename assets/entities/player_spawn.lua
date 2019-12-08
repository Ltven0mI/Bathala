local Class = require "hump.class"
local Vector = require "hump.vector"

local SpriteLoader = require "core.spriteloader"

local Entity = require "classes.entity"

local PlayerSpawn = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 16, 16, 16)
    end,

    sprite = SpriteLoader.loadFromOBJ("assets/meshes/billboard16x16.obj", "assets/images/player/player_spawn.png", true),
    tags = {"player_spawn"},
}

function PlayerSpawn:update(dt)

end

function PlayerSpawn:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

return PlayerSpawn