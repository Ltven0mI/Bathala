local Class = require "hump.class"
local Maf = require "core.maf"

local Collider = Class{
    init = function(self, x, y, z, width, height, depth)
        self.pos = Maf.vector(x, y, z)
        self.width = width
        self.height = height
        self.depth = depth
    end,

    colliderOffsetX = 0,
    colliderOffsetY = 0,
    colliderOffsetZ = 0,

    colliderIsSolid = false,
}

function Collider:setPos(x, y, z)
    self.pos.x = x
    self.pos.y = y
    self.pos.z = z
    self.map.bumpWorld:update(self, self:getWorldCoords())
end

function Collider:move(dx, dy, dz)
    local currentX, currentY, currentZ = self:getWorldCoords()
    local actualX, actualY, actualZ, cols, len = self.map.bumpWorld:move(self, currentX+dx, currentY+dy, currentZ+dz, self.filter)
    self.pos.x, self.pos.y, self.pos.z = self:getRealCoords(actualX, actualY, actualZ)
    return cols
end

function Collider:onRegistered(map)
    self.map = map
end

function Collider:onUnregistered()
    self.map = nil
end

function Collider:filter(other)
    if not other.isColliderSolid then
        return nil
    end
    return "slide"
end


function Collider:getRealCoords(x, y, z)
    return self.width/2 + x - self.colliderOffsetX,
    self.height/2 + y - self.colliderOffsetY,
    self.depth/2 + z - self.colliderOffsetZ
end

function Collider:getWorldCoords()
    return self.colliderOffsetX + self.pos.x - self.width / 2, self.colliderOffsetY + self.pos.y - self.height / 2, self.colliderOffsetZ + self.pos.z - self.depth / 2
end

function Collider:getBounds()
    error(string.format("getBounds() was called but is not implemented for collider type '%s'", self.colliderType))
end

function Collider:drawWireframe()
    error(string.format("drawWireframe() was called but is not implemented for collider type '%s'", self.colliderType))
end

function Collider:intersect(other)
    local collisionChecker = self.collisionCheckers[other.colliderType] or self.collisionCheckers["*"]
    return collisionChecker(self, other)
end

function Collider:intersectPoint(x, y, z)
    error(string.format("intersectPoint() was called but is not implemented for collider type '%s'", self.colliderType))
end

return Collider