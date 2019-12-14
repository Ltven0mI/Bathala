local Class = require "hump.class"

local Entity = require "classes.entity"

local Spawner = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z)
    end,

    spriteMeshFile="assets/meshes/billboard16x16_flat.obj",
    spriteImgFile="assets/images/tiles/spawner.png",
    spriteIsTransparent=true,

    tags = {"spawner"}
}

return Spawner