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

    canPickUp = true,
    type = "pickupable",
}

function Pickupable:draw()
    self:drawCollisionBox()
end

function Pickupable:drawHeld()
    self:drawCollisionBox()
end

function Pickupable:pickup(player)
    if not self.canPickUp then
        return
    end
    self.map:unregisterEntity(self)
    self.player = player
    self.player.heldItem = self
end

function Pickupable:putdown(x, y)
    self.pos.x = x
    self.pos.y = y
    self.player.map:registerEntity(self)
    self.player.heldItem = nil
    self.player = nil
end

function Pickupable:use(map, x, y, dir)

end

return Pickupable