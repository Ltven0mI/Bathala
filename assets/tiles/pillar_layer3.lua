local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer3 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    img = love.graphics.newImage("assets/images/tiles/pillar_layer3.png"),
}

return PillarLayer3