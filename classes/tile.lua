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
    layerHeight = 1,
    offsetX = 0,
    offsetY = 0,
}

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    local imgH = self.img.image:getHeight()
    local worldX, worldY = self.map:gridToWorldPos(self.gridX, self.gridY, 1)
    local depth = self.map:getDepthAtWorldPos(worldX + self.offsetX, worldY + self.offsetY + imgH, (self.layerId - 1) + self.layerHeight)
    local transform = DepthManager.getTranslationTransform(self.pos.x + self.offsetX, self.pos.y + self.offsetY, depth)

    love.graphics.setColor(1, 1, 1, 1)
    self.img:draw(transform)
end

return Tile