local Class = require "hump.class"

local Pickupable = require "classes.pickupable"

local UseItem = Class{
    __includes = {Pickupable},
    init = function(self, x, y, z, width, height, depth)
        Pickupable.init(self, x, y, z, width, height, depth)
        self.player = nil
    end,

    hudIcon=nil,

    tags = {"useitem", "pickupable"},
}

function UseItem:pickup(player)
    self.map:unregisterEntity(self)
    self.player = player
    self.player.currentUseItem = self
end

function UseItem:putDown(x, y, z, map)
    self.pos.x = x
    self.pos.y = y
    self.pos.z = z
    map:registerEntity(self)
    self.player.currentUseItem = nil
    self.player = nil
end

return UseItem