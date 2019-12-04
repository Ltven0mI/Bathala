local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local GroundSmooth = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/ground_smooth.png",
    spriteIsTransparent=false,
}

return GroundSmooth