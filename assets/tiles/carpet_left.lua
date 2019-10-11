local Class = require "hump.class"

local Tile = require "classes.tile"

local CarpetLeft = Class{
    init = function(self, map, x, y)
        Tile.init(self, map, x, y)
    end,
    __includes={ Tile },
    img = love.graphics.newImage("assets/images/tiles/carpet_left.png"),
}

return CarpetLeft