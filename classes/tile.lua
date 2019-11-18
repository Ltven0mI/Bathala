local Class = require "hump.class"
local Vector = require "hump.vector"

local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local Tile = Class{
    init = function(self, map, x, y, layerId)
        self.gridX = x
        self.gridY = y
        self.layerId = layerId
        self.pos = Vector(map:gridToWorldPos(x, y, layerId))
        self.collider = ColliderBox(self, 0, 0, map.tileSize, map.tileSize)
        self.map = map
    end,
    isSolid = false,
}

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    local worldX, worldY = self.map:gridToWorldPos(self.gridX, self.gridY, 1)
    local depth = self.map:getDepthAtWorldPos(worldX, worldY, self.layerId)
    local transform = DepthManager.getTranslationTransform(self.pos.x, self.pos.y, depth)

    love.graphics.setColor(1, 1, 1, 1)
    self.img:draw(transform)
end

return Tile