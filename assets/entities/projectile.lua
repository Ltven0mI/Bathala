local Class = require "hump.class"
local Maf = require "core.maf"

local Animations = require "core.animations"
local Entities = require "core.entities"

local Entity = require "classes.entity"

local Projectile = Class{
    __includes = {Entity},
    init = function(self, x, y, z, dir)
        Entity.init(self, x, y, z, 16, 16, 16)
        self.dir = dir or Maf.vector(0, 0, 0)
        self.timer = 0
    end,

    spriteMeshFile=nil,
    spriteImgFile=nil,
    spriteIsTransparent=false,

    vfxName=nil,

    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = nil,

    tags = {"projectile"},
}

function Projectile:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.timeToLive then
        self:destroy()
    end

    self.pos = self.pos + self.dir * self.speed * dt
    -- TODO: Reimplement projectile collisions
    -- if self.map then
    --     local hitEntities = self.map:getEntitiesInCollider(self.collider, self.tagMask)
    --     if hitEntities then
    --         if hitEntities[1].takeDamage then hitEntities[1]:takeDamage(self.damage) end
    --         self:destroy()
    --     else
    --         local hitTiles = self.map:getTilesInCollider(self.collider, self.tagMask)
    --         if hitTiles then
    --             if hitTiles[1].takeDamage then hitTiles[1]:takeDamage(self.damage) end
    --             self:destroy()
    --         end
    --     end
    -- end
end

function Projectile:draw()
    -- TODO: Add rotation to Sprite drawing
    -- local rot = -(self.dir:toPolar().x) + math.pi / 2

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function Projectile:destroy()
    if self.vfxName ~= nil then
        local vfx = Entities.new(self.vfxName, self.pos.x, self.pos.y, self.pos.z, love.timer.getTime() * 60)
        self.map:registerEntity(vfx)
    end
    self.map:unregisterEntity(self)
end

return Projectile