local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer1 = Class{
    __includes={Tile},
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/pillar_base.obj",
    spriteImgFile="assets/images/tiles/pillar_base1.png",
    spriteIsTransparent=false,

    width = 16,
    height = 3,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 1.5,
    colliderOffsetZ = 0,

    extraColliders = {
        {0, 8, 0, 10, 16, 10}
    }
}

return PillarLayer1