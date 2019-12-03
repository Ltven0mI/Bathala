local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local CarpetRight = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/tile_ground.obj", "assets/images/tiles/carpet_right.png", false)
    end,
    __includes={ Tile },
}

return CarpetRight