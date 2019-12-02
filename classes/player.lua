local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local DepthManager = require "core.depthmanager"
local SpriteLoader = require "core.spriteloader"

local Peachy = require "peachy"

local ColliderBox = require "classes.collider_box"

local Projectile = require "assets.entities.curse_projectile"

local player = Class{
    init = function(self, x, y, z)
        self.pos = Maf.vector(x, y, z)
        self.w = 10
        self.h = 16

        self.collider = ColliderBox(self, -5, -4, 10, 4)

        self.health = 10

        self.moveProgress = 0

        self.velocity = Maf.vector(0, 0, 0)
        self.lastVelocity = Maf.vector(0, 0, 0)

        self.lookDirection = "down"

        self.map = nil
        self.isGameOver = false
        self.heldItem = nil
        self.currentUseItem = nil

        Signal.register("gameover", function(...) self:onGameOver(...) end)

        self.animation = Peachy.new("assets/images/player/player.json", love.graphics.newImage("assets/images/player/player.png"), "walk_down")
        self.animation:onLoop(function() self:animation_loop() end )
        self.animation:stop()

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/billboard16x16.obj", self.spriteCanvas, true)

        self.healthBarCanvas = love.graphics.newCanvas(69, 13)
    end,

    healthBarImg = love.graphics.newImage("assets/images/ui/health_bar.png"),
    healthBarFillImg = love.graphics.newImage("assets/images/ui/health_bar_fill.png"),
    useItemBgImg = love.graphics.newImage("assets/images/ui/useitem_bg.png"),
    useItemTextImg = love.graphics.newImage("assets/images/ui/useitem_text.png"),
    pickupText = love.graphics.newImage("assets/images/ui/pickup_text.png"),

    speed = 64,
    maxHealth = 10,
    tag = "player",
    type="player",
}

function player:setMap(map)
    self.map = map
end

function player:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health <= 0 then
        Signal.emit("player-died")
    end
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
    local deltaY = (w and 1 or 0) + (s and -1 or 0)
    local inputDelta = Maf.vector(deltaX, deltaY):normalize()

    self.moveProgress = self.moveProgress + #inputDelta * self.speed * dt
    local flooredProgress = self.moveProgress --math.floor(self.moveProgress)
    self.moveProgress = self.moveProgress - flooredProgress

    self.velocity = inputDelta * flooredProgress

    self.pos = self.pos + self.velocity

    if deltaY > 0 then
        self.animation:setTag("walk_up")
        self.lookDirection = "up"
    elseif deltaY < 0 then
        self.animation:setTag("walk_down")
        self.lookDirection = "down"
    else
        if deltaX < 0 then
            self.animation:setTag("walk_left")
            self.lookDirection = "left"
        elseif deltaX > 0 then
            self.animation:setTag("walk_right")
            self.lookDirection = "right"
        end
    end

    local isMovingNow = #self.velocity > 0
    local wasMovingBefore = #self.lastVelocity > 0
    if isMovingNow and not wasMovingBefore then
        self.animation:play()
    elseif wasMovingBefore and not isMovingNow then
        self.animation:stop()
    end

    self:doCollisionCheck()

    if self.pos.x < 0 or self.pos.x > self.map.width * self.map.tileSize or
    self.pos.y < 0 or self.pos.y > self.map.height * self.map.tileSize then
        self:takeDamage(self.health)
    end
end

function player:updateSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function player:draw()
    local imgW = self.animation:getWidth()
    local halfImgW = math.floor(imgW / 2)

    self:updateSpriteCanvas()

    local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 1.25)
    local xPos = self.pos.x - halfImgW
    local yPos = self.pos.y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
    -- love.graphics.draw(newMeshTest, Util3D.getTranslationTransform(self.pos:unpack()))

    -- [[ Debug ]] --

    -- self.collider:drawWireframe()
    -- love.graphics.circle("fill", self.pos.x, self.pos.y, 1)

    -- [[ End Debug ]] --

    if self.heldItem then
        self.heldItem:drawHeld(self.pos.x, self.pos.y - self.h, depth - self.h)
    end

    local pickupables = self.map:getEntitiesInCollider(self.collider, "pickupable")
    local pickupable = nil
    if pickupables then
        for _, v in ipairs(pickupables) do
            if v.canPickUp and v:canPickUp() then
                pickupable = v
                break
            end
        end
    end
    if pickupable and self.heldItem == nil then
        local textW, textH = self.pickupText:getDimensions()
        local halfTextW, halfTextH = math.floor(textW / 2), math.floor(textH / 2)
        love.graphics.draw(self.pickupText, self.pos.x - halfTextW, self.pos.y - self.h - textH - 1)
    end
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
    if btn == 3 then
        self.pos.y = self.pos.y - 0.1
    end

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
            local pickupables = self.map:getEntitiesInCollider(self.collider, "pickupable")
            local pickupable = nil
            if pickupables then
                for _, v in ipairs(pickupables) do
                    if v.canPickUp and v:canPickUp() then
                        pickupable = v
                        break
                    end
                end
            end
            if pickupable then
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
    local posX, posY = self.collider:getWorldCoords()
    local minX = math.floor(posX)
    local maxX = math.floor(posX + self.w)
    local minY = math.floor(posY)
    local maxY = math.floor(posY + self.h)

    local gridMinX, gridMinY = self.map:worldToGridPos(minX, minY)
    local gridMaxX, gridMaxY = self.map:worldToGridPos(maxX, maxY)

    for x=gridMinX, gridMaxX do
        for y=gridMinY, gridMaxY do
            local tileData = self.map:getTileAt(x, y, 2)
            if tileData and tileData.isSolid then
                local worldX, worldY = self.map:gridToWorldPos(x, y)
                -- TODO: Need to add colliders to tiles.
                local collider = ColliderBox({pos=Maf.vector(worldX, worldY)}, tileData.collider.x, tileData.collider.y, tileData.collider.w, tileData.collider.h)
                self.collider:checkAndDispatchCollision(collider, self.velocity.x, self.velocity.y)
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