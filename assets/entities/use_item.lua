local Class = require "hump.class"
local Vector = require "hump.vector"

local Pickupable = require "classes.pickupable"

local UseItem = Class{
    init = function(self, x, y, z, w, h)
        Pickupable.init(self, x, y, z, w, h)
        self.player = nil
    end,
    __includes = {
        Pickupable
    },
    icon=nil,
    tag = "pickupable",
}

function UseItem:pickup(player)
    self.map:unregisterEntity(self)
    self.player = player
    self.player.currentUseItem = self
end

function UseItem:putDown(x, y, map)
    self.pos.x = x
    self.pos.y = y
    map:registerEntity(self)
    self.player.currentUseItem = nil
    self.player = nil
end

return UseItem