local Class = require "hump.class"
local Maf = require "core.maf"

local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local Entity = Class{
    init = function(self, x, y, z, w, h)
        self.collider = ColliderBox(self, 0, 0, w, h)
        self.pos = Maf.vector(x, y, z)
        self.w = w
        self.h = h
        self.map = nil
    end,
    __includes = {
    },
    isSolid = false,
}

function Entity:start()

end

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