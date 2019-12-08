local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local PlayerSpawn = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 16, 16, 16)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/player/player_spawn.png",
    spriteIsTransparent=false,

    tags = {"player_spawn"},
}

function PlayerSpawn:update(dt)

end

return PlayerSpawn