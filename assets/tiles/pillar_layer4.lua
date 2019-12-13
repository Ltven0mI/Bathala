local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer4 = Class{
    __includes={Tile},
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/pillar_top.obj",
    spriteImgFile="assets/images/tiles/pillar_layer4.png",
    spriteIsTransparent=false,

    width = 16,
    height = 3,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 14.5,
    colliderOffsetZ = 0,

    extraColliders = {
        {0, 8, 0, 10, 16, 10}
    }
}

return PillarLayer4