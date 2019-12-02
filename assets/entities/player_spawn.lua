local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local PlayerSpawn = Class{
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 16, 16)
    end,
    __includes = {
        Entity
    },

    img = love.graphics.newImage("assets/images/tiles/player_spawn.png"),
    type = "player_spawn",
}

function PlayerSpawn:update(dt)

end

function PlayerSpawn:draw()
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

return PlayerSpawn