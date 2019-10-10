local Class = require "hump.class"
local Vector = require "hump.vector"

local Tile = Class{
    init = function(self, map, x, y)
        self.pos = Vector(x, y)
        self.map = map
    end,
    __includes = {
    },
}

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    
end

return Tile