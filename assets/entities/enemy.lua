local Class = require "hump.class"

local Entity = require "classes.entity"

local Enemy = Class{
    init = function(self, x, y, w, h)
        Entity.init(self, x, y, w, h)
    end,
    __includes = {
        Entity
    },
    speed = 32,
    img = love.graphics.newImage("assets/desecrator/desecrator_temp.png")
}

function Enemy:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

return Enemy