local Class = require "hump.class"
local Vector = require "hump.vector"

local player = Class{
    init = function(self, img)
        self.pos = Vector(0, 0)
        self.moveProgress = 0
        self.img = img
        self.map = nil
    end,
    speed = 64,
    size = 16
}

function player:setMap(map)
    self.map = map
end

function player:correctCollisionLeft()
    if not self.map then return end
    
    local halfPlayerSize = math.floor(self.size / 2)

    local selfX, selfY = self.pos:unpack()

    local gridX1, gridY1 = self.map:worldToGridPos(selfX, selfY - (halfPlayerSize - 1))
    local gridX2, gridY2 = self.map:worldToGridPos(selfX, selfY + (halfPlayerSize - 1))
    gridX1 = gridX1 - 1
    gridX2 = gridX2 - 1
    local tile1 = self.map:getTileAt(gridX1, gridY1)
    local tile2 = self.map:getTileAt(gridX2, gridY2)
    if (tile1 == nil or not tile1.isSolid) and (tile2 == nil or not tile2.isSolid) then return end

    local tileX, tileY = self.map:gridToWorldPos(gridX1, gridY1)
    self.pos.x = math.max(self.pos.x, tileX + self.map.tileSize + halfPlayerSize)
end

function player:correctCollisionRight()
    if not self.map then return end
    
    local halfPlayerSize = math.floor(self.size / 2)

    local selfX, selfY = self.pos:unpack()

    local gridX1, gridY1 = self.map:worldToGridPos(selfX, selfY - (halfPlayerSize - 1))
    local gridX2, gridY2 = self.map:worldToGridPos(selfX, selfY + (halfPlayerSize - 1))
    gridX1 = gridX1 + 1
    gridX2 = gridX2 + 1
    local tile1 = self.map:getTileAt(gridX1, gridY1)
    local tile2 = self.map:getTileAt(gridX2, gridY2)
    if (tile1 == nil or not tile1.isSolid) and (tile2 == nil or not tile2.isSolid) then return end

    local tileX, tileY = self.map:gridToWorldPos(gridX1, gridY1)
    self.pos.x = math.min(self.pos.x, tileX - halfPlayerSize)
end

function player:correctCollisionUp()
    if not self.map then return end
    
    local halfPlayerSize = math.floor(self.size / 2)

    local selfX, selfY = self.pos:unpack()

    local gridX1, gridY1 = self.map:worldToGridPos(selfX - (halfPlayerSize - 1), selfY)
    local gridX2, gridY2 = self.map:worldToGridPos(selfX + (halfPlayerSize - 1), selfY)
    gridY1 = gridY1 - 1
    gridY2 = gridY2 - 1
    local tile1 = self.map:getTileAt(gridX1, gridY1)
    local tile2 = self.map:getTileAt(gridX2, gridY2)
    if (tile1 == nil or not tile1.isSolid) and (tile2 == nil or not tile2.isSolid) then return end

    local tileX, tileY = self.map:gridToWorldPos(gridX1, gridY1)
    self.pos.y = math.max(self.pos.y, tileY + self.map.tileSize + halfPlayerSize)
end

function player:correctCollisionDown()
    if not self.map then return end
    
    local halfPlayerSize = math.floor(self.size / 2)

    local selfX, selfY = self.pos:unpack()

    local gridX1, gridY1 = self.map:worldToGridPos(selfX - (halfPlayerSize - 1), selfY)
    local gridX2, gridY2 = self.map:worldToGridPos(selfX + (halfPlayerSize - 1), selfY)
    gridY1 = gridY1 + 1
    gridY2 = gridY2 + 1
    local tile1 = self.map:getTileAt(gridX1, gridY1)
    local tile2 = self.map:getTileAt(gridX2, gridY2)
    if (tile1 == nil or not tile1.isSolid) and (tile2 == nil or not tile2.isSolid) then return end

    local tileX, tileY = self.map:gridToWorldPos(gridX1, gridY1)
    self.pos.y = math.min(self.pos.y, tileY - halfPlayerSize)
end

function player:update(dt)
    local w = love.keyboard.isDown("w")
    local a = love.keyboard.isDown("a")
    local s = love.keyboard.isDown("s")
    local d = love.keyboard.isDown("d")

    local deltaX = (a and -1 or 0) + (d and 1 or 0)
    local deltaY = (w and -1 or 0) + (s and 1 or 0)
    local inputDelta = Vector(deltaX, deltaY):normalized()

    self.moveProgress = self.moveProgress + inputDelta:len() * self.speed * dt
    local flooredProgress = self.moveProgress --math.floor(self.moveProgress)
    self.moveProgress = self.moveProgress - flooredProgress

    self.pos = self.pos + inputDelta * flooredProgress

    if inputDelta.x < 0 then
        self:correctCollisionLeft()
    end
    if inputDelta.x > 0 then
        self:correctCollisionRight()
    end
    if inputDelta.y < 0 then
        self:correctCollisionUp()
    end
    if inputDelta.y > 0 then
        self:correctCollisionDown()
    end
end

function player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local halfPlayerSize = math.floor(self.size / 2)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, halfPlayerSize, halfPlayerSize)
end

return player