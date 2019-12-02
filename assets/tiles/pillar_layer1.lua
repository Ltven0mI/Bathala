local Class = require "hump.class"
local Tile = require "classes.tile"
local Sprites = require "core.sprites"

local DepthManager = require "core.depthmanager"

local PillarLayer1 = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },
    isSolid = true,
    img = Sprites.new("assets/images/tiles/pillar_base1.png", {isGround=true}),
}

-- function PillarLayer1:draw()
--     local worldX, worldY = self.map:gridToWorldPos(self.gridX, self.gridY, 1)
--     local depth = self.map:getDepthAtWorldPos(worldX, worldY+self.map.tileSize, 1.25)
--     local transform = DepthManager.getTranslationTransform(self.pos.x, self.pos.y, depth)

--     love.graphics.setColor(1, 1, 1, 1)
--     self.img:draw(transform)
-- end

return PillarLayer1