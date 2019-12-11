local Class = require "hump.class"
local Tile = require "classes.tile"

local Wall = Class{
    __includes={ Tile },
    init = function(self, map, x, y, z)
        Tile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/cube.obj",
    spriteImgFile="assets/images/tiles/wall_plain.png",
    spriteIsTransparent=false
}

return Wall