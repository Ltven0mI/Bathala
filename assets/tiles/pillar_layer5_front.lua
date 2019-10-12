local Class = require "hump.class"
local Tile = require "classes.tile"

local PillarLayer5Front = Class{
    init = function(self, map, x, y)
        Tile.init(self, map, x, y)
    end,
    __includes={ Tile },
    isSolid = true,
    img = love.graphics.newImage("assets/images/tiles/pillar_layer5_front.png"),
}

return PillarLayer5Front