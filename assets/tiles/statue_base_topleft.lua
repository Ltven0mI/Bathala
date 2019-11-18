local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local ColliderBox = require "classes.collider_box"

local StatueBaseTopLeft = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.collider = ColliderBox(self, 4, 7, 12, 9)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/statue_base_topleft.png"),
}

return StatueBaseTopLeft