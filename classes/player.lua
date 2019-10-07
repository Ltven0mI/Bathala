local Class = require "hump.class"
local Vector = require "hump.vector"

local Collidable = require "classes.collidable"

local player = Class{
    init = function(self, img, x, y, w, h)
        Collidable.init(self, x, y, w, h)
        self.moveProgress = 0
        self.img = img
        self.map = nil
    end,
    speed = 64,
}
player:include(Collidable)

function player:setMap(map)
    self.map = map
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

    local movementDelta = inputDelta * flooredProgress

    self.pos = self.pos + movementDelta

    local minX = math.floor(self.pos.x)
    local maxX = math.floor(self.pos.x + self.w)
    local minY = math.floor(self.pos.y)
    local maxY = math.floor(self.pos.y + self.h)

    gridMinX, gridMinY = self.map:worldToGridPos(minX, minY)
    gridMaxX, gridMaxY = self.map:worldToGridPos(maxX, maxY)

    for x=gridMinX, gridMaxX do
        for y=gridMinY, gridMaxY do
            local tileData = self.map:getTileAt(x, y, 2)
            if tileData and tileData.isSolid then
                local worldX, worldY = self.map:gridToWorldPos(x, y)
                local collidable = Collidable(worldX + tileData.collider.x, worldY + tileData.collider.y, tileData.collider.w, tileData.collider.h)
                self:checkForCollision(collidable, movementDelta.x, movementDelta.y)
            end
        end
    end
end

function player:draw()
    -- local minX = math.floor(self.pos.x)
    -- local maxX = math.floor(self.pos.x + self.w)
    -- local minY = math.floor(self.pos.y)
    -- local maxY = math.floor(self.pos.y + self.h)

    -- gridMinX, gridMinY = self.map:worldToGridPos(minX, minY)
    -- gridMaxX, gridMaxY = self.map:worldToGridPos(maxX, maxY)

    -- for x=gridMinX, gridMaxX do
    --     for y=gridMinY, gridMaxY do
    --         local tileData = self.map:getTileAt(x, y)
    --         if tileData and tileData.isSolid then
    --             local worldX, worldY = self.map:gridToWorldPos(x, y)
    --             love.graphics.rectangle("line", worldX + tileData.collider.x, worldY + tileData.collider.y, tileData.collider.w, tileData.collider.h)
    --         end
    --     end
    -- end

    love.graphics.setColor(1, 1, 1, 1)
    local imgW, imgH = self.img:getDimensions()
    local halfImgW = math.floor(imgW / 2)
    local halfImgH = math.floor(imgH / 2)
    local halfPlayerW = math.floor(self.w / 2)
    local halfPlayerH = math.floor(self.h / 2)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, halfImgW-halfPlayerW, halfImgH-halfPlayerH)
    -- love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)
end

return player