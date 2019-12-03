local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local GroundCracked = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/tile_ground.obj", "assets/images/tiles/ground_cracked.png", false)
    end,
    __includes={ Tile },
}

return GroundCracked