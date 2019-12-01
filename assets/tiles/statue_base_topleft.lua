local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local StatueBaseTopLeft = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.collider = ColliderBox(self, 4, 7, 12, 9)
    end,
    __includes={ Tile },
    isSolid = true,
    layerHeight = 0.25,
    offsetX = 4,
    offsetY = 7,
    img = Sprites.new("assets/images/tiles/statue_base_topleft.png", {isGround=true}),
}

return StatueBaseTopLeft