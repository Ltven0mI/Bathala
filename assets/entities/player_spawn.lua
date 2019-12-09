local Class = require "hump.class"

local Entity = require "classes.entity"

local PlayerSpawn = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 16, 16, 16)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/entities/player_spawn.png",
    spriteIsTransparent=false,

    tags = {"player_spawn"},
}

return PlayerSpawn