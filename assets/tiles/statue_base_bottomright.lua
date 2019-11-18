local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local ColliderBox = require "classes.collider_box"

local StatueBaseBottomRight = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.collider = ColliderBox(self, 0, 0, 12, 10)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/statue_base_bottomright.png"),
}

return StatueBaseBottomRight