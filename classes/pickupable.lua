local Class = require "hump.class"
local Vector = require "hump.vector"

local Entity = require "classes.entity"

local Pickupable = Class{
    init = function(self, x, y, w, h)
        Entity.init(self, x, y, w, h)
        self.player = nil
    end,
    __includes = {
        Entity
    },
    type = "pickupable",
}

function Pickupable:draw()
    self:drawCollisionBox()
end

function Pickupable:drawHeld()
    self:drawCollisionBox()
end

function Pickupable:canPickUp()
    return true
end

function Pickupable:use(map, x, y, dir)

end

function Pickupable:pickup(player)
    self.map:unregisterEntity(self)
    self.player = player
    self.player.heldItem = self
end

function Pickupable:putDown(x, y, map)
    self.pos.x = x
    self.pos.y = y
    map:registerEntity(self)
    self.player.heldItem = nil
    self.player = nil
end

return Pickupable