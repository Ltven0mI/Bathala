local Class = require "hump.class"
local Vector = require "hump.vector"

local Projectile = require "assets.entities.projectile"

local DesecratorProjectile = Class{
    init = function(self, x, y, dir)
        Projectile.init(self, x, y, dir)
    end,
    __includes = {
        Projectile
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    img = love.graphics.newImage("assets/desecrator/desecrator_projectile.png"),

    type = "projectile",
}

function DesecratorProjectile:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.timeToLive then
        self:destroy()
    end

    self.pos = self.pos + self.dir * self.speed * dt
    if self.map then
        local hitEntity = self.map:getEntityAt(self.pos.x, self.pos.y, "statue")
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

return DesecratorProjectile