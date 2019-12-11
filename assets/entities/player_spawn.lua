local Class = require "hump.class"

local Entity = require "classes.entity"

local PlayerSpawn = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z)
    end,

    width = 16,
    height = 16,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 8,
    colliderOffsetZ = 0,
    
    isColliderSolid = false,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/entities/player_spawn.png",
    spriteIsTransparent=false,

    tags = {"player_spawn"},
}

return PlayerSpawn