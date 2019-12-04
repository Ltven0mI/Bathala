local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer2 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,

    spriteMeshFile="assets/meshes/pillar_column.obj",
    spriteImgFile="assets/images/tiles/pillar_layer2.png",
    spriteIsTransparent=false,
}

return PillarLayer2