local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer3 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/pillar_column.obj", "assets/images/tiles/pillar_layer3.png", false)
    end,
    __includes={ Tile },
    isSolid = true,
}

return PillarLayer3