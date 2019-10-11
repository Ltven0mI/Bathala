local Class = require "hump.class"
local Vector = require "hump.vector"

local ColliderBox = require "classes.collider_box"

local Tile = Class{
    init = function(self, map, x, y)
        self.gridX = x
        self.gridY = y
        self.pos = Vector(map:gridToWorldPos(x, y))
        self.collider = ColliderBox(0, 0, map.tileSize, map.tileSize)
        self.map = map
    end,
}

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

return Tile