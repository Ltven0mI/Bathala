local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Pickupable = require "classes.pickupable"

local CurseProjectile = require "assets.entities.curse_projectile"

local CursePowerup = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
    end,
    __includes = {
        Pickupable
    },
    img = love.graphics.newImage("assets/powerups/curse_powerup_temp.png"),

    type = "pickupable",
}

function CursePowerup:update(dt)

end

function CursePowerup:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

function CursePowerup:drawHeld(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, x, y)
end

function CursePowerup:use(map, x, y, dir)
    local instance = CurseProjectile(x, y, dir)
    self.player.map:registerEntity(instance)
end

return CursePowerup