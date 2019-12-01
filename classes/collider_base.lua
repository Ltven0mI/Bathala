local Class = require "hump.class"
local Vector = require "hump.vector"

local ColliderBase = Class{
    init = function(self, obj, x, y)
        self.obj = obj
        self.x = x or 0
        self.y = y or 0
    end,
    collisionHandlers = {["*"] = function() end},
    collisionCheckers = {["*"] = function() return false end},
    colliderType = "base"
}

function ColliderBase:checkAndDispatchCollision(other, dx, dy)
    local collisionChecker = self.collisionCheckers[other.colliderType] or self.collisionCheckers["*"]
    if collisionChecker(self, other, dx, dy) then
        self:dispatchCollision(other, dx, dy)
    end
end

function ColliderBase:dispatchCollision(other, dx, dy)
    local collisionHandler = self.collisionHandlers[other.colliderType] or self.collisionHandlers["*"]
    return collisionHandler(self, other, dx, dy)
end

function ColliderBase:getWorldCoords()
    return self.obj.pos.x + self.x, self.obj.pos.y + self.y
end

function ColliderBase:getBounds()
    error(string.format("getBounds() was called but is not implemented for collider type '%s'", self.colliderType))
end

function ColliderBase:drawWireframe()
    error(string.format("drawWireframe() was called but is not implemented for collider type '%s'", self.colliderType))
end

function ColliderBase:intersect(other)
    local collisionChecker = self.collisionCheckers[other.colliderType] or self.collisionCheckers["*"]
    return collisionChecker(self, other, dx, dy)
end

function ColliderBase:intersectPoint(x, y)
    error(string.format("intersectPoint() was called but is not implemented for collider type '%s'", self.colliderType))
end

return ColliderBase