local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local Wall = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },

    spriteMeshFile="assets/meshes/cube.obj",
    spriteImgFile="assets/images/tiles/wall_plain.png",
    spriteIsTransparent=false,

    isSolid = true,
}

return Wall