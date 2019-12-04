local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local CarpetLeft = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/carpet_left.png",
    spriteIsTransparent=false,
}

return CarpetLeft