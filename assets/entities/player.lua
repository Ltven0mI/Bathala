local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local Animations = require "core.animations"
local SpriteLoader = require "core.spriteloader"
local Util3D = require "core.util3d"

local Entity = require "classes.entity"

local Player = Class{
    __includes={Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z)

        self.health = 10

        self.moveProgress = 0

        self.velocity = Maf.vector(0, 0, 0)
        self.lastVelocity = Maf.vector(0, 0, 0)

        self.lookDirection = "down"

        -- ? vvv Probably worth centralizing this variable... vvv
        self.isGameOver = false
        self.heldItem = nil
        self.currentUseItem = nil

        Signal.register("gameover", function(...) self:onGameOver(...) end)

        self.animation = Animations.new("player", "walk_down")
        self.animation:onLoop(function()
            if self.animation.peach.tagName == "death" then
                self.animation:stop(true)
            end
        end)
        self.animation:stop()

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite:setTexture(self.spriteCanvas)

        self.healthBarCanvas = love.graphics.newCanvas(69, 13)
    end,

    width = 10,
    height = 16,
    depth = 4,

    colliderOffsetX = 0,
    colliderOffsetY = 8,
    colliderOffsetZ = 2,
    
    isColliderSolid = false,
    
    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/entities/player_icon.png",
    spriteIsTransparent=false,

    healthBarImg = love.graphics.newImage("assets/images/ui/health_bar.png"),
    healthBarFillImg = love.graphics.newImage("assets/images/ui/health_bar_fill.png"),
    useItemBgImg = love.graphics.newImage("assets/images/ui/useitem_bg.png"),
    useItemTextImg = love.graphics.newImage("assets/images/ui/useitem_text.png"),
    pickupTextSprite = SpriteLoader.createSprite(Util3D.generateMesh(28, 7, 0), "assets/images/ui/pickup_text.png", true),

    speed = 64,
    maxHealth = 10,

    pickupExpansion = 4,

    tags = {"player"},
}

-- [[ Util Functions ]] --

function Player:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health <= 0 then
        Signal.emit("player-died")
    end
end

function Player:pickUpItem(item)
    item:pickup(self)
end

function Player:putDownHeldItem()
    self.heldItem:putDown(self.pos.x, self.pos.y, self.pos.z, self.map)
end
-- \\ End Util Functions // --


-- [[ Callback Functions ]] --

function Player:update(dt)
    self.animation:update(dt)

    if self.isGameOver then
        return
    end

    self.lastVelocity = self.velocity:clone()


    local w = love.keyboard.isDown("w")
    local a = love.keyboard.isDown("a")
    local s = love.keyboard.isDown("s")
    local d = love.keyboard.isDown("d")

    local q = love.keyboard.isDown("q")
    local e = love.keyboard.isDown("e")

    local deltaX = (a and -1 or 0) + (d and 1 or 0)
    local deltaY = (q and -1 or 0) + (e and 1 or 0)
    local deltaZ = (w and 1 or 0) + (s and -1 or 0)
    local inputDelta = Maf.vector(deltaX, deltaY, deltaZ):normalize()

    self.velocity = inputDelta * self.speed
    self:move((self.velocity * dt):unpack())


    if deltaZ > 0 then
        self.animation:setTag("walk_up")
        self.lookDirection = "up"
    elseif deltaZ < 0 then
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

    -- Kill player if outside of map bounds
    -- if self.pos.x < 0 or self.pos.x > self.map.width * self.map.tileSize or
    -- self.pos.y < 0 or self.pos.y > self.map.height * self.map.tileSize or
    -- self.pos.z < 0 or self.pos.z > self.map.depth * self.map.tileSize then
    --     self:takeDamage(self.health)
    -- end
end

function Player:redrawSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function Player:draw()
    local imgW = self.animation:getWidth()
    local halfImgW = math.floor(imgW / 2)

    self:redrawSpriteCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())

    if self.heldItem then
        -- ? This may be incorrect
        self.heldItem:drawHeld(self.pos.x, self.pos.y + self.height, self.pos.z)
    else
        local x, y, z = self:getWorldCoords()
        x = x - self.pickupExpansion / 2
        y = y - self.pickupExpansion / 2
        z = z - self.pickupExpansion / 2
        local w, h, d = self.width + self.pickupExpansion, self.height + self.pickupExpansion, self.depth + self.pickupExpansion
        local collided, colliders = self.map:checkCube(x, y, z, w, h, d, "pickupable")
        if collided then
            local canPickUp = false
            for _, other in ipairs(colliders) do
                if other.canPickUp and other:canPickUp() then
                    canPickUp = true
                    break
                end
            end
            if canPickUp then
                self.pickupTextSprite:draw(self.pos.x, self.pos.y + self.height + 4.5, self.pos.z)
            end
        end
    end

end

function Player:drawUI(screenW, screenH)
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
        love.graphics.draw(self.currentUseItem.hudIcon, drawX, drawY)
        if not self.heldItem then
            love.graphics.draw(self.useItemTextImg, drawX, drawY)
        end
    end

end

function Player:mousepressed(btn, dir)
    if self.isGameOver then
        return
    end

    if self.heldItem then
        if btn == 1 then
            self.heldItem:use(self.map, self.pos.x, self.pos.y, self.pos.z, dir)
        elseif btn == 2 then
            self:putDownHeldItem()
        end
    else
        if btn == 1 then
            local x, y, z = self:getWorldCoords()
            x = x - self.pickupExpansion / 2
            y = y - self.pickupExpansion / 2
            z = z - self.pickupExpansion / 2
            local w, h, d = self.width + self.pickupExpansion, self.height + self.pickupExpansion, self.depth + self.pickupExpansion
            local collided, colliders = self.map:checkCube(x, y, z, w, h, d, "pickupable")
            if collided then
                local closestPickupable = nil
                local closestDistance = math.huge
                
                for _, other in ipairs(colliders) do
                    if other.canPickUp and other:canPickUp() then
                        local distance = self.pos:distance(other.pos)
                        if distance < closestDistance then
                            closestPickupable = other
                            closestDistance = distance
                        end
                    end
                end
                if closestPickupable then
                    self:pickUpItem(closestPickupable)
                elseif self.currentUseItem then
                    self.currentUseItem:use(self.map, self.pos.x, self.pos.y, self.pos.z, dir)
                end
            end
        end
    end
end

function Player:onGameOver()
    self.isGameOver = true
    self.animation:setTag("death")
    self.animation:play()
end
-- \\ End Callback Functions // --

return Player