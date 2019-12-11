local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer3 = Class{
    __includes={Tile},
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/pillar_column.obj",
    spriteImgFile="assets/images/tiles/pillar_layer3.png",
    spriteIsTransparent=false
}

return PillarLayer3