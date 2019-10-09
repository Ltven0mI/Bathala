local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Peachy = require "lib.peachy"

local Collidable = require "classes.collidable"

local Projectile = require "assets.entities.curse_projectile"

local player = Class{
    init = function(self, img, x, y, w, h)
        Collidable.init(self, x, y, w, h)

        self.health = 10

        self.moveProgress = 0

        self.velocity = Vector(0, 0)
        self.lastVelocity = Vector(0, 0)

        self.map = nil
        self.isGameOver = false
        self.heldItem = nil
        self.currentUseItem = nil

        Signal.register("gameover", function(...) self:onGameOver(...) end)

        self.animation = Peachy.new("assets/player/player.json", love.graphics.newImage("assets/player/player.png"), "walk_down")
        self.animation:onLoop(function() self:animation_loop() end )
        self.animation:stop()

        self.healthBarCanvas = love.graphics.newCanvas(69, 13)
    end,

    healthBarImg = love.graphics.newImage("assets/ui/health_bar.png"),
    healthBarFillImg = love.graphics.newImage("assets/ui/health_bar_fill.png"),
    useItemBgImg = love.graphics.newImage("assets/ui/useitem_bg.png"),
    useItemTextImg = love.graphics.newImage("assets/ui/useitem_text.png"),

    speed = 64,
    maxHealth = 10,
    type="player",
}
player:include(Collidable)

function player:setMap(map)
    self.map = map
end

function player:update(dt)
    self.animation:update(dt)

    if self.isGameOver then
        return
    end

    self.lastVelocity = self.velocity:clone()


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

    self.velocity = inputDelta * flooredProgress

    self.pos = self.pos + self.velocity

    if deltaY < 0 then
        self.animation:setTag("walk_up")
    elseif deltaY > 0 then
        self.animation:setTag("walk_down")
    else
        if deltaX < 0 then
            self.animation:setTag("walk_left")
        elseif deltaX > 0 then
            self.animation:setTag("walk_right")
        end
    end

    local isMovingNow = self.velocity:len() > 0
    local wasMovingBefore = self.lastVelocity:len() > 0
    if isMovingNow and not wasMovingBefore then
        self.animation:play()
    elseif wasMovingBefore and not isMovingNow then
        self.animation:stop()
    end

    self:doCollisionCheck()
end

function player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local imgW, imgH = self.animation:getWidth(), self.animation:getHeight()
    local halfImgW = math.floor(imgW / 2)
    local halfImgH = math.floor(imgH / 2)
    local halfPlayerW = math.floor(self.w / 2)
    local halfPlayerH = math.floor(self.h / 2)

    -- if self.velocity.y < 0 then
    --     if self.heldItem then
    --         self.heldItem:drawHeld(self.pos.x, self.pos.y)
    --     end
    -- end
    self.animation:draw(self.pos.x, self.pos.y, 0, 1, 1, halfImgW-halfPlayerW, halfImgH-halfPlayerH)
    -- if self.velocity.y >= 0 then
        if self.heldItem then
            self.heldItem:drawHeld(self.pos.x, self.pos.y - 10)
        end
    -- end
    
    -- love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)
end

function player:drawUI(screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)

    local halfScreenW = math.floor(screenW / 2)
    local barW, barH = self.healthBarImg:getDimensions()
    local halfBarW = math.floor(barW / 2)

    love.graphics.push("all")
    love.graphics.origin()

    local lastCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.healthBarCanvas)
    love.graphics.clear()

    love.graphics.draw(self.healthBarImg, 0, 0)

    love.graphics.setScissor(13, 0, 53 * (self.health / self.maxHealth), barH)
    love.graphics.draw(self.healthBarFillImg, 0, 0)
    love.graphics.setScissor()

    love.graphics.setCanvas(lastCanvas)
    love.graphics.pop()

    local drawX, drawY = halfScreenW - halfBarW, screenH - barH - 1

    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.healthBarCanvas, drawX, drawY)
    love.graphics.setBlendMode("alpha")

    if self.heldItem then
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
    end

    local useItemW, useItemH = self.useItemBgImg:getDimensions()
    local drawX, drawY = drawX + barW + 1, screenH - useItemH - 2
    love.graphics.draw(self.useItemBgImg, drawX, drawY)
    if self.currentUseItem then
        love.graphics.draw(self.currentUseItem.icon, drawX, drawY)
        if not self.heldItem then
            love.graphics.draw(self.useItemTextImg, drawX, drawY)
        end
    end

end

function player:mousepressed(btn, dir)
    if self.isGameOver then
        return
    end

    if self.heldItem then
        if btn == 1 then
            self.heldItem:use(self.map, self.pos.x, self.pos.y, dir)
        elseif btn == 2 then
            self:putDownHeldItem()
        end
    else
        if btn == 1 then
            local halfPlayerW = math.floor(self.w / 2)
            local halfPlayerH = math.floor(self.h / 2)
            local pickupable = self.map:getEntityAt(self.pos.x + halfPlayerW, self.pos.y + halfPlayerH, "pickupable")
            if pickupable and pickupable:canPickUp() then
                self:pickUpItem(pickupable)
            elseif self.currentUseItem then
                self.currentUseItem:use(self.map, self.pos.x, self.pos.y, dir)
            end
        end
    end
end

function player:onGameOver()
    self.isGameOver = true
    self.animation:setTag("death")
    self.animation:play()
end

function player:animation_loop()
    if self.animation.tagName == "death" then
        self.animation:stop(true)
    end
end

function player:doCollisionCheck()
    local minX = math.floor(self.pos.x)
    local maxX = math.floor(self.pos.x + self.w)
    local minY = math.floor(self.pos.y)
    local maxY = math.floor(self.pos.y + self.h)

    local gridMinX, gridMinY = self.map:worldToGridPos(minX, minY)
    local gridMaxX, gridMaxY = self.map:worldToGridPos(maxX, maxY)

    for x=gridMinX, gridMaxX do
        for y=gridMinY, gridMaxY do
            local tileData = self.map:getTileAt(x, y, 2)
            if tileData and tileData.isSolid then
                local worldX, worldY = self.map:gridToWorldPos(x, y)
                local collidable = Collidable(worldX + tileData.collider.x, worldY + tileData.collider.y, tileData.collider.w, tileData.collider.h)
                self:checkForCollision(collidable, self.velocity.x, self.velocity.y)
            end
        end
    end
end

function player:pickUpItem(item)
    item:pickup(self)
end

function player:putDownHeldItem()
    self.heldItem:putDown(self.pos.x, self.pos.y, self.map)
end

return player