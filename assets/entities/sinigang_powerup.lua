local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Pickupable = require "classes.pickupable"

local SinigangPowerup = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
    end,
    __includes = {
        Pickupable
    },
    healAmount = 20,
    img = love.graphics.newImage("assets/powerups/sinigang_powerup_temp.png"),

    type = "pickupable",
}

function SinigangPowerup:update(dt)

end

function SinigangPowerup:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

function SinigangPowerup:drawHeld(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, x, y)
end

function SinigangPowerup:use(map, x, y, dir)
    Signal.emit("statue-heal", self.healAmount)
    self.player.heldItem = nil
    self.player = nil
end

return SinigangPowerup