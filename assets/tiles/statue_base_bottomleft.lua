local Class = require "hump.class"
local Tile = require "classes.tile"

local ColliderBox = require "classes.collider_box"

local StatueBaseBottomLeft = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.collider = ColliderBox(self, 4, 0, 12, 10)
    end,
    __includes={ Tile },
    isSolid = true,
    img = love.graphics.newImage("assets/images/tiles/statue_base_bottomleft.png"),
}

return StatueBaseBottomLeft