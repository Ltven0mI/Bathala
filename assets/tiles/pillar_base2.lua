local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local PillarBase2 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/pillar_base2.png"),
}

return PillarBase2