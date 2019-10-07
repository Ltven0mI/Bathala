local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local Projectile = Class{
    init = function(self, x, y, dir)
        Entity.init(self, x, y, 16, 16)
        self.dir = dir
        self.timer = 0
    end,
    __includes = {
        Entity
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    img = love.graphics.newImage("assets/desecrator/desecrator_projectile.png"),

    type = "projectile",
}

function Projectile:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.timeToLive then
        self:destroy()
    end

    self.pos = self.pos + self.dir * self.speed * dt
    if self.map then
        local hitEntity = self.map:getEntityAt(self.pos.x, self.pos.y, "enemy")
        if hitEntity then
            hitEntity:takeDamage(self.damage)
            self:destroy()
        else
            local gridX, gridY = self.map:worldToGridPos(self.pos:unpack())
            local tileData = self.map:getTileAt(gridX, gridY, 2)
            if tileData then
                if tileData.isSolid then
                    self:destroy()
                end
            end
        end
    end
end

function Projectile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local rot = -(self.dir:toPolar().x) + math.pi / 2
    local halfW, halfH = math.floor(self.w / 2), math.floor(self.h / 2)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, rot, 1, 1, halfW, halfH)
end

function Projectile:destroy()
    self.map:unregisterEntity(self)
end

return Projectile