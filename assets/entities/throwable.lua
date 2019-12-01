local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"

local Entity = require "classes.entity"
local Pickupable = require "classes.pickupable"
local Sfx = require "classes.sfx"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local Throwable = Class{
    init = function(self, x, y, w, h)
        Pickupable.init(self, x, y, w, h)
        self.collider = ColliderBox(self, -math.floor(w/2), -h, w, h)
        self.isThrown = false
        self.isSmashed = false
        self.velocity = Vector(0, 0)
    end,
    __includes = {
        Pickupable
    },
    damage=3,
    drag=4,
    velocityCutoff = 48,
    throwSpeed = 256,
    img = Sprites.new("assets/images/tiles/boulder.png"),
    imgBroken = Sprites.new("assets/images/tiles/boulder_broken.png"),
    smashSfx = nil,

    type = "pickupable",
}

function Throwable:update(dt)
    if self.isThrown then
        self.pos = self.pos + self.velocity * dt
        local drag = (not self.isSmashed and self.drag or self.drag * 2)
        self.velocity = self.velocity - (self.velocity * drag * dt)
        if not self.isSmashed and self.velocity:len() < self.velocityCutoff then
            self:smash()
        end

        if not self.isSmashed and self.map then
            local hitEntities = self.map:getEntitiesInCollider(self.collider, "enemy")
            if hitEntities then
                hitEntities[1]:takeDamage(self.damage)
                self:smash()
            else
                local hitTiles = self.map:getTilesInCollider(self.collider)
                if hitTiles then
                    self:smash()
                end
            end
        end
    end
end

function Throwable:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local img = self.img
    if self.isSmashed then
        img = self.imgBroken
    end

    local depth = self:getDepth()
    local xPos = self.pos.x - math.floor(self.w / 2)
    local yPos = self.pos.y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    img:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
end

function Throwable:getDepth()
    if self.isSmashed then
        return self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 1.125)
    else
        return Entity.getDepth(self)
    end
end

function Throwable:canPickUp()
    return not self.isThrown
end

function Throwable:use(map, x, y, dir)
    self:putDown(x, y, map)
    self.isThrown = true
    self.velocity = dir * self.throwSpeed
end

function Throwable:smash()
    self.type = ""
    self.isSmashed = true
    if self.smashSfx then
        self.smashSfx:play()
    end
end

return Throwable