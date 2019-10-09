local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Pickupable = require "classes.pickupable"
local Sfx = require "classes.sfx"

local Throwable = Class{
    init = function(self, x, y, w, h)
        Pickupable.init(self, x, y, w, h)
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
    img = love.graphics.newImage("assets/tiles/boulder.png"),
    imgBroken = love.graphics.newImage("assets/tiles/boulder_broken.png"),
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
            local hitEntity = self.map:getEntityAt(self.pos.x, self.pos.y, "enemy")
            if hitEntity then
                hitEntity:takeDamage(self.damage)
                self:smash()
            else
                local gridX, gridY = self.map:worldToGridPos(self.pos:unpack())
                local tileData = self.map:getTileAt(gridX, gridY, 2)
                if tileData then
                    if tileData.isSolid then
                        self:smash()
                    end
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
    love.graphics.draw(img, self.pos.x, self.pos.y)
end

function Throwable:drawHeld(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, x, y)
end

function Throwable:use(map, x, y, dir)
    self:putdown(x, y)
    self.isThrown = true
    self.canPickUp = false
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