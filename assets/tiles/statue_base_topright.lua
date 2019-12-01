local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local StatueBaseTopRight = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.collider = ColliderBox(self, 0, 7, 12, 9)
    end,
    __includes={ Tile },
    isSolid = true,
    layerHeight = 0.25,
    offsetX = 0,
    offsetY = 7,
    img = Sprites.new("assets/images/tiles/statue_base_topright.png", {isGround=true}),
}

return StatueBaseTopRight