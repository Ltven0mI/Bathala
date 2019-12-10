local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarBase1 = Class{
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,
    __includes={ Tile },
    isSolid = true,

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/pillar_base1.png",
    spriteIsTransparent=false,
}

return PillarBase1