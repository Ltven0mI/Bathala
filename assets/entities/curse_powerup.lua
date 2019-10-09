local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local UseItem = require "assets.entities.use_item"

local CurseProjectile = require "assets.entities.curse_projectile"

local CursePowerup = Class{
    init = function(self, x, y)
        UseItem.init(self, x, y, 16, 16)
    end,
    __includes = {
        UseItem
    },

    isUsable=true,

    img = love.graphics.newImage("assets/powerups/curse_powerup_temp.png"),
    icon = love.graphics.newImage("assets/powerups/curse_powerup_icon.png"),

    type = "pickupable",
}

function CursePowerup:update(dt)

end

function CursePowerup:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

function CursePowerup:use(map, x, y, dir)
    local instance = CurseProjectile(x, y, dir)
    self.player.map:registerEntity(instance)
end

return CursePowerup