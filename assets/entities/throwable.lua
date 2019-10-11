local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"

local Pickupable = require "classes.pickupable"
local Sfx = require "classes.sfx"

local Throwable = Class{
    init = function(self, x, y, w, h)
        Pickupable.init(self, x, y, w, h)
        self.collider = ColliderBox(self, -math.floor(w/2), -h, w, h)
        self.isThrown = false
        self.isSmashed = false
        self.velocity = Vector(0, 0)
    end,
    __includes = {
        Pickupable
    },
    damage=3,
    drag=4,
    velocityCutoff = 48,
    throwSpeed = 256,
    img = love.graphics.newImage("assets/images/tiles/boulder.png"),
    imgBroken = love.graphics.newImage("assets/images/tiles/boulder_broken.png"),
    smashSfx = nil,

    type = "pickupable",
}

function Throwable:update(dt)
    if self.isThrown then
        self.pos = self.pos + self.velocity * dt
        local drag = (not self.isSmashed and self.drag or self.drag * 2)
        self.velocity = self.velocity - (self.velocity * drag * dt)
        if not self.isSmashed and self.velocity:len() < self.velocityCutoff then
            self:smash()
        end

        if not self.isSmashed and self.map then
            local hitEntities = self.map:getEntitiesInCollider(self.collider, "enemy")
            if hitEntities then
                hitEntities[1]:takeDamage(self.damage)
                self:smash()
            else
                local hitTiles = self.map:getTilesInCollider(self.collider)
                if hitTiles then
                    self:smash()
                end
            end
        end
    end
end

function Throwable:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local img = self.img
    if self.isSmashed then
        img = self.imgBroken
    end
    love.graphics.draw(img, self.pos.x, self.pos.y, 0, 1, 1, math.floor(self.w / 2), self.h)
    -- self.collider:drawWireframe()

    -- local worldX, worldY = self.collider:getWorldCoords()
    -- local minGridX, minGridY = self.map:worldToGridPos(worldX, worldY)
    -- local maxGridX, maxGridY = self.map:worldToGridPos(worldX + self.collider.w, worldY + self.collider.h)

    -- for x=minGridX, maxGridX do
    --     for y=minGridY, maxGridY do
    --         local tileWorldX, tileWorldY = self.map:gridToWorldPos(x, y)
    --         love.graphics.rectangle("line", tileWorldX, tileWorldY, 16, 16)
    --     end
    -- end
end

function Throwable:canPickUp()
    return not self.isThrown
end

function Throwable:use(map, x, y, dir)
    self:putDown(x, y, map)
    self.isThrown = true
    self.velocity = dir * self.throwSpeed
end

function Throwable:smash()
    self.type = ""
    self.isSmashed = true
    if self.smashSfx then
        self.smashSfx:play()
    end
end

return Throwable