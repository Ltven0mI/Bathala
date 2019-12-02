local Class = require "hump.class"
local Vector = require "hump.vector"

local Animations = require "core.animations"
local Sprites = require "core.sprites"
local Entities = require "core.entities"
local DepthManager = require "core.depthmanager"

local Entity = require "classes.entity"

local Projectile = Class{
    init = function(self, x, y, z, dir)
        Entity.init(self, x, y, z, 16, 16)
        self.dir = dir
        self.timer = 0
    end,
    __includes = {
        Entity
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = nil,
    img = Sprites.new("assets/images/projectiles/desecrator_projectile.png"),

    type = "projectile",
    tag = "projectile",
}

function Projectile:getDepth()
    return self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 2)
end

function Projectile:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.timeToLive then
        self:destroy()
    end

    self.pos = self.pos + self.dir * self.speed * dt
    if self.map then
        local hitEntities = self.map:getEntitiesInCollider(self.collider, self.tagMask)
        if hitEntities then
            if hitEntities[1].takeDamage then hitEntities[1]:takeDamage(self.damage) end
            self:destroy()
        else
            local hitTiles = self.map:getTilesInCollider(self.collider, self.tagMask)
            if hitTiles then
                if hitTiles[1].takeDamage then hitTiles[1]:takeDamage(self.damage) end
                self:destroy()
            end
        end
    end
end

function Projectile:draw()
    local rot = -(self.dir:toPolar().x) + math.pi / 2
    local halfW, halfH = math.floor(self.w / 2), math.floor(self.h / 2)

    local depth = self:getDepth()
    local xPos = self.pos.x - self.w
    local yPos = self.pos.y - halfH

    local transform = DepthManager.getTranslationTransform(self.pos.x, self.pos.y, depth):rotate(rot):translate(-self.w, -halfH)

    love.graphics.setColor(1, 1, 1, 1)
    self.img:draw(transform)
end

function Projectile:destroy()
    local explosion = Entities.new("vfx", self.pos.x, self.pos.y, Animations.new("magic_explosion", "default"), love.timer.getTime() * 60)
    self.map:registerEntity(explosion)
    self.map:unregisterEntity(self)
end

return Projectile