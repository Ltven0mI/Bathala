local Class = require "hump.class"
local Vector = require "hump.vector"

local Collidable = require "classes.collidable"

local Entity = Class{
    init = function(self, x, y, w, h)
        Collidable.init(self, x, y, w, h)
        self.map = nil
    end,
    __includes = {
        Collidable
    },
}

function Entity:update(dt)

end

function Entity:draw()
    love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)
end

function Entity:onRegistered(map)
    self.map = map
end

function Entity:onUnregistered()
    self.map = nil
end

return Entity