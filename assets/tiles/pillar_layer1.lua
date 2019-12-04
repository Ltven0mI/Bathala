local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer1 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,

    spriteMeshFile="assets/meshes/pillar_base.obj",
    spriteImgFile="assets/images/tiles/pillar_base1.png",
    spriteIsTransparent=false,
}

return PillarLayer1