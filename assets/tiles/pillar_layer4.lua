local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer4 = Class{
    __includes={Tile},
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/pillar_top.obj",
    spriteImgFile="assets/images/tiles/pillar_layer4.png",
    spriteIsTransparent=false
}

return PillarLayer4