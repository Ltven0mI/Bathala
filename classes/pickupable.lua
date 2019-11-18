local Class = require "hump.class"
local Vector = require "hump.vector"

local DepthManager = require "core.depthmanager"

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
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, math.floor(self.w / 2), self.h)
    self.collider:drawWireframe()
end

function Pickupable:drawHeld(x, y, z)
    local xPos = x - math.floor(self.w / 2)
    local yPos = y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    self.img:draw(DepthManager.getTranslationTransform(xPos, yPos, z))
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