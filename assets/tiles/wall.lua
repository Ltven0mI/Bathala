local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local Wall = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    layerHeight=0.25,
    img = Sprites.new("assets/images/tiles/pillar_layer5.png", {isGround=true}),
}

function Wall:draw()
    
end

return Wall