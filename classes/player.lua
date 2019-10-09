local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Collidable = require "classes.collidable"

local Projectile = require "assets.entities.curse_projectile"

local player = Class{
    init = function(self, img, x, y, w, h)
        Collidable.init(self, x, y, w, h)
        self.moveProgress = 0
        self.img = img
        self.map = nil
        self.isGameOver = false
        self.heldItem = nil
        Signal.register("gameover", function(...) self:onGameOver(...) end)
    end,
    speed = 64,
    gameoverImg = love.graphics.newImage("assets/player/player_gameover.png"),
    type="player",
}
player:include(Collidable)

function player:setMap(map)
    self.map = map
end

function player:update(dt)
    if self.isGameOver then
        return
    end

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
    love.graphics.setColor(1, 1, 1, 1)
    local imgW, imgH = self.img:getDimensions()
    local halfImgW = math.floor(imgW / 2)
    local halfImgH = math.floor(imgH / 2)
    local halfPlayerW = math.floor(self.w / 2)
    local halfPlayerH = math.floor(self.h / 2)
    local img = self.img
    if self.isGameOver then
        img = self.gameoverImg
    end
    love.graphics.draw(img, self.pos.x, self.pos.y, 0, 1, 1, halfImgW-halfPlayerW, halfImgH-halfPlayerH)
    if self.heldItem then
        self.heldItem:drawHeld(self.pos.x, self.pos.y)
    end
    -- love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)
end

function player:mousepressed(btn, dir)
    if self.isGameOver then
        return
    end

    if self.heldItem then
        if btn == 1 then
            self.heldItem:use(self.map, self.pos.x, self.pos.y, dir)
        elseif btn == 2 then
            self.heldItem:putdown(self.pos.x, self.pos.y)
        end
    else
        if btn == 1 then
            local halfPlayerW = math.floor(self.w / 2)
            local halfPlayerH = math.floor(self.h / 2)
            local pickupable = self.map:getEntityAt(self.pos.x + halfPlayerW, self.pos.y + halfPlayerH, "pickupable")
            if pickupable then
                pickupable:pickup(self)
            end
        end
    end
end

function player:onGameOver()
    self.isGameOver = true
end

return player