local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local GroundSmooth = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    img = Sprites.new("assets/images/tiles/ground_smooth.png", {isGround=true}),
}

return GroundSmooth