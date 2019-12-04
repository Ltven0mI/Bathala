local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer3 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,

    spriteMeshFile="assets/meshes/pillar_column.obj",
    spriteImgFile="assets/images/tiles/pillar_layer3.png",
    spriteIsTransparent=false,
}

return PillarLayer3