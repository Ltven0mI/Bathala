local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local Spawner = Class{
    init = function(self, x, y)
        Entity.init(self, x, y, 16, 16)
    end,
    __includes = {
        Entity
    },

    img = love.graphics.newImage("assets/images/tiles/spawner.png"),
    type = "spawner",
    tag = "spawner"
}

function Spawner:update(dt)

end

function Spawner:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

return Spawner