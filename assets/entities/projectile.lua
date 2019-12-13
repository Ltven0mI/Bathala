local Class = require "hump.class"
local Maf = require "core.maf"

local Animations = require "core.animations"
local Entities = require "core.entities"

local Entity = require "classes.entity"

local Projectile = Class{
    __includes = {Entity},
    init = function(self, x, y, z, dir)
        Entity.init(self, x, y, z)
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

    local collisions = self:move((self.dir * self.speed * dt):unpack())
    if collisions and #collisions > 0 then
        for _, collision in ipairs(collisions) do
            local entity = collision.other
            if entity.hasTag and entity:hasTag("enemy") then
                if entity.takeDamage then entity:takeDamage(self.damage) end
            end
            self:destroy()
            break
        end
    end
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