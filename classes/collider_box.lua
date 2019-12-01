local Class = require "hump.class"
local Vector = require "hump.vector"

local ColliderBase = require "classes.collider_base"

local ColliderBox = Class{
    init = function(self, obj, x, y, w, h)
        ColliderBase.init(self, obj, x, y)
        self.w = w or 0
        self.h = h or 0
    end,
    __includes = {
        ColliderBase
    },
    collisionHandlers = {["*"] = function() end},
    collisionCheckers = {["*"] = function() return false end},
    colliderType = "box"
}

ColliderBox.collisionCheckers["box"] = function(self, other, dx, dy)
    local selfWorldX, selfWorldY = self:getWorldCoords()
    local otherWorldX, otherWorldY = other:getWorldCoords()

    return (
        selfWorldX < otherWorldX + other.w and selfWorldX + self.w >= otherWorldX and
        selfWorldY < otherWorldY + other.h and selfWorldY + self.h >= otherWorldY
    )
end

ColliderBox.collisionHandlers["box"] = function(self, other, dx, dy)
    local selfWorldX, selfWorldY = self:getWorldCoords()
    local otherWorldX, otherWorldY = other:getWorldCoords()

    local depthX = math.min(selfWorldX + self.w, otherWorldX + other.w) - math.max(selfWorldX, otherWorldX)
    local depthY = math.min(selfWorldY + self.h, otherWorldY + other.h) - math.max(selfWorldY, otherWorldY)

    local xDepth = 0
    if dx < 0 then
        xDepth = (otherWorldX + other.w) - (selfWorldX)
    elseif dx > 0 then
        xDepth = (otherWorldX) - (selfWorldX + self.w)
    end

    local yDepth = 0
    if dy < 0 then
        yDepth = (otherWorldY + other.h) - (selfWorldY)
    elseif dy > 0 then  
        yDepth = (otherWorldY) - (selfWorldY + self.h)
    end

    if (xDepth ~= 0 and math.abs(xDepth) < math.abs(yDepth)) or (yDepth == 0 and depthY > 0) then
        self.obj.pos.x = (selfWorldX + math.abs(xDepth) * (dx > 0 and -1 or 1)) - self.x
    elseif math.abs(xDepth) > math.abs(yDepth) or (xDepth == 0 and depthX > 0) then
        self.obj.pos.y = (selfWorldY + math.abs(yDepth) * (dy > 0 and -1 or 1)) - self.y
    end
end

function ColliderBox:getBounds()
    return self.x, self.y, self.w, self.h
end

function ColliderBox:drawWireframe()
    local selfWorldX, selfWorldY = self:getWorldCoords()
    love.graphics.rectangle("fill", selfWorldX, selfWorldY, self.w, 1)
    love.graphics.rectangle("fill", selfWorldX, selfWorldY+self.h-1, self.w, 1)
    love.graphics.rectangle("fill", selfWorldX, selfWorldY, 1, self.h)
    love.graphics.rectangle("fill", selfWorldX+self.w-1, selfWorldY, 1, self.h)
end

function ColliderBox:intersectPoint(x, y)
    local selfWorldX, selfWorldY = self:getWorldCoords()
    return (
        x >= selfWorldX and x < selfWorldX + self.w and
        y >= selfWorldY and y < selfWorldY + self.h
    )
end

return ColliderBox