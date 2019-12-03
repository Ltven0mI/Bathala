local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"

local PillarLayer1 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/pillar_base.obj", "assets/images/tiles/pillar_base1.png", false)
    end,
    __includes={ Tile },
    isSolid = true,
}

return PillarLayer1