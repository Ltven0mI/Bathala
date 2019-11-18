local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local PillarLayer2 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/pillar_layer2.png"),
}

return PillarLayer2