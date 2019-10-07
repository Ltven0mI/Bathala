local Class = require "hump.class"
local AssetBundle = require "AssetBundle"

local Map = Class{
    init = function(self, mapData, tileset)
        self.width = mapData.width
        self.height = mapData.height
        self.layouts = mapData.layouts
        self.layerCount = #self.layouts
        self.mapData = mapData
        self.tileset = tileset
    end,
    tileSize=16
}

function Map:worldToGridPos(x, y, layerId)
    local layerId = layerId or 1
    return math.floor(x / self.tileSize) + 1, math.floor(y / self.tileSize) + math.max(1, layerId-1)
end

function Map:gridToWorldPos(x, y, layerId)
    local layerId = layerId or 1
    return (x-1) * self.tileSize, (y-math.max(1, layerId-1)) * self.tileSize
end

function Map:getTileAt(x, y, layerId)
    local layerId = layerId or 1
    if x < 1 or y < 1 or x > self.width or y > self.height or layerId < 1 or layerId > self.layerCount then
        return nil
    end
    return self.grids[layerId][x][y]
end

function Map:setTileAt(tileData, x, y, layerId)
    local layerId = layerId or 1
    if x < 1 or y < 1 or x > self.width or y > self.height or layerId < 1 or layerId > self.layerCount then
        return nil
    end
    self.grids[layerId][x][y] = tileData
end

function Map:generateGrid()
    self.grids = {}

    for i=1, #self.layouts do
        self.grids[i] = {}
        for x=1, self.width do
            self.grids[i][x] = {}
            for y=1, self.height do
                local id = self.layouts[i][x][y]
                local tileKey = self.mapData.tileIndex[id]
                if tileKey then
                    self.grids[i][x][y] = self.tileset.tiles[tileKey]
                end
            end
        end
    end
end

function Map:draw(minLayer, maxLayer)
    local minLayer = minLayer or 1
    local maxLayer = maxLayer or self.layerCount

    love.graphics.setColor(1, 1, 1, 1)
    -- local offsetX = math.floor(self.width * self.tileSize / 2)
    -- local offsetY = math.floor(self.height * self.tileSize / 2)

    for i=minLayer, maxLayer do
        for x=1, self.width do
            for y=1, self.height do
                local tileData = self.grids[i][x][y]

                if tileData ~= nil then
                    local drawX, drawY = (x-1) * self.tileSize, (y-math.max(1, i-1)) * self.tileSize
                    love.graphics.draw(tileData.img, drawX, drawY)
                end
            end
        end
    end
end

return Map