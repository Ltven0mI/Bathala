local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Pickupable = require "classes.pickupable"

local Vase = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
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
    img = love.graphics.newImage("assets/tiles/vase.png"),
    imgBroken = love.graphics.newImage("assets/tiles/vase_broken.png"),

    type = "pickupable",
}

function Vase:update(dt)
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

function Vase:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local img = self.img
    if self.isSmashed then
        img = self.imgBroken
    end
    love.graphics.draw(img, self.pos.x, self.pos.y)
end

function Vase:drawHeld(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, x, y)
end

function Vase:use(map, x, y, dir)
    self:putdown(x, y)
    self.isThrown = true
    self.canPickUp = false
    self.velocity = dir * self.throwSpeed
end

function Vase:smash()
    self.type = ""
    self.isSmashed = true
    Signal.emit("vase-smashed", self.pos.x, self.pos.y)
end

return Vase