local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarBase1 = Class{
    __includes={ Tile },
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/pillar_base1.png",
    spriteIsTransparent=false
}

return PillarBase1