local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local Statue = Class{
    init = function(self, x, y)
        Entity.init(self, x, y, 32, 48)
        self.health = 10
    end,
    __includes = {
        Entity
    },
    aliveImg = love.graphics.newImage("assets/tiles/bathala_statue.png"),
    rubbleImg = love.graphics.newImage("assets/tiles/bathala_statue_rubble.png"),

    type = "statue",
    baseOffset = Vector(16, 32),
}

function Statue:update(dt)

end

function Statue:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    local img = self.aliveImg
    if self.health == 0 then
        img = self.rubbleImg
    end

    love.graphics.draw(img, self.pos.x, self.pos.y)
end

return Statue