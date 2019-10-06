local Class = require "hump.class"

local Map = Class{
    init = function(self, mapData)
        self.width = mapData.width
        self.height = mapData.height
        self.grid = mapData.grid
    end,
    tileSize=16
}

function Map:worldToGridPos(x, y)
    return math.floor(x / self.tileSize) + 1, math.floor(y / self.tileSize) + 1
end

function Map:gridToWorldPos(x, y)
    return (x-1) * self.tileSize, (y-1) * self.tileSize
end

function Map:getTileAt(x, y)
    if x < 1 or y < 1 or x > self.width or y > self.height then
        return nil
    end
    return self.grid[x][y]
end

function Map:draw()
    love.graphics.setColor(1, 1, 1, 1)
    -- local offsetX = math.floor(self.width * self.tileSize / 2)
    -- local offsetY = math.floor(self.height * self.tileSize / 2)

    for x=1, self.width do
        for y=1, self.height do
            local tileData = self.grid[x][y]

            if tileData == 0 then
                love.graphics.setColor(1, 1, 1, 1)
            elseif tileData == 1 then
                love.graphics.setColor(1, 0, 0, 1)
            end

            local drawX, drawY = (x-1) * self.tileSize, (y-1) * self.tileSize
            love.graphics.rectangle("fill", drawX, drawY, self.tileSize, self.tileSize)
            love.graphics.print(tileData, drawX, drawY)
        end
    end
end

return Map