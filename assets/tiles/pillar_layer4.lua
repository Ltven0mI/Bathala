local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer4 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,

    spriteMeshFile="assets/meshes/pillar_top.obj",
    spriteImgFile="assets/images/tiles/pillar_layer4.png",
    spriteIsTransparent=false,
}

return PillarLayer4