local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local PillarLayer3 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/pillar_layer3.png"),
}

return PillarLayer3