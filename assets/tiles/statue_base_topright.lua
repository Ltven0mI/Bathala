local Class = require "hump.class"
local Tile = require "classes.tile"

local ColliderBox = require "classes.collider_box"

local StatueBaseTopRight = Class{
    init = function(self, map, x, y)
        Tile.init(self, map, x, y)
        self.collider = ColliderBox(self, 0, 7, 12, 9)
    end,
    __includes={ Tile },
    isSolid = true,
    img = love.graphics.newImage("assets/images/tiles/statue_base_topright.png"),
}

return StatueBaseTopRight