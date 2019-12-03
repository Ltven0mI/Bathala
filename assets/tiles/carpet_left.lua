local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local CarpetLeft = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/tile_ground.obj", "assets/images/tiles/carpet_left.png", false)
    end,
    __includes={ Tile },
}

return CarpetLeft