local Class = require "hump.class"
local Vector = require "hump.vector"

local Collidable = Class{
    init = function(self, x, y, w, h)
        self.type = "collidable"
        self.pos = Vector(x, y)
        self.w = w
        self.h = h
    end,
    collision_handler = {["*"] = function() end},
}

Collidable.collision_handler["collidable"] = function(self, other, dx, dy)
    local depthX = math.min(self.pos.x + self.w, other.pos.x + other.w) - math.max(self.pos.x, other.pos.x)
    local depthY = math.min(self.pos.y + self.h, other.pos.y + other.h) - math.max(self.pos.y, other.pos.y)

    local xDepth = 0
    if dx < 0 then
        xDepth = (other.pos.x + other.w) - (self.pos.x)
    elseif dx > 0 then
        xDepth = (other.pos.x) - (self.pos.x + self.w)
    end

    local yDepth = 0
    if dy < 0 then
        yDepth = (other.pos.y + other.h) - (self.pos.y)
    elseif dy > 0 then
        yDepth = (other.pos.y) - (self.pos.y + self.h)
    end

    if (xDepth ~= 0 and math.abs(xDepth) < math.abs(yDepth)) or (yDepth == 0 and depthY > 0) then
        self.pos.x = self.pos.x + math.abs(xDepth) * (dx > 0 and -1 or 1)
    elseif math.abs(xDepth) > math.abs(yDepth) or (xDepth == 0 and depthX > 0) then
        self.pos.y = self.pos.y + math.abs(yDepth) * (dy > 0 and -1 or 1)
    end
end

function Collidable:checkForCollision(other, dx, dy)
    if self:intersect(other) then
        self:dispatch_collision(other, dx, dy)
    end
end

function Collidable:dispatch_collision(other, dx, dy)
    if self.collision_handler[other.type] then
        return self.collision_handler[other.type](self, other, dx, dy)
    end
    return self.collision_handler["*"](self, other, dx, dy)
end

function Collidable:intersect(other)
    return (
        self.pos.x < other.pos.x + other.w and self.pos.x + self.w >= other.pos.x and
        self.pos.y < other.pos.y + other.h and self.pos.y + self.h >= other.pos.y
    )
end

return Collidable