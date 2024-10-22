local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Entity = require "classes.entity"

local Statue = Class{
    init = function(self, x, y)
        Entity.init(self, x, y, 32, 48)
        self.health = 60
    end,
    __includes = {
        Entity
    },
    maxHealth = 60,
    aliveImg = love.graphics.newImage("assets/tiles/bathala_statue.png"),
    rubbleImg = love.graphics.newImage("assets/tiles/bathala_statue_rubble.png"),

    type = "statue",
    baseOffset = Vector(16, 32),
}

function Statue:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health == 0 then
        Signal.emit("statue-died", self)
    end
end

function Statue:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Statue:update(dt)

end

function Statue:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    local img = self.aliveImg
    if self.health == 0 then
        img = self.rubbleImg
    end

    love.graphics.draw(img, self.pos.x, self.pos.y)
    
    local barX = self.pos.x
    local barY = self.pos.y-3

    local barW = self.w
    local barH = 2

    love.graphics.setColor(0.2, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", barX-1, barY-1, barW+2, barH+2)
    love.graphics.setColor(162/256, 31/256, 31/256, 1)
    love.graphics.rectangle("fill", barX, barY, barW * (self.health / self.maxHealth), barH)
end

return Statue