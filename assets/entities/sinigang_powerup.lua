local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Peachy = require "lib.peachy"

local ColliderBox = require "classes.collider_box"

local Pickupable = require "classes.pickupable"

local SinigangPowerup = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -16, 16, 16)
        self.animation = Peachy.new("assets/images/powerups/sinigang_powerup.json", love.graphics.newImage("assets/images/powerups/sinigang_powerup.png"), "idle")
    end,
    __includes = {
        Pickupable
    },
    healAmount = 20,
    img = love.graphics.newImage("assets/images/powerups/sinigang_powerup_held.png"),

    tag = "pickupable",
}

function SinigangPowerup:update(dt)
    self.animation:update(dt)
end

function SinigangPowerup:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(self.pos.x, self.pos.y, 0, 1, 1, math.floor(self.w / 2), self.h)
end

function SinigangPowerup:use(map, x, y, dir)
    Signal.emit("statue-heal", self.healAmount)
    self.player.heldItem = nil
    self.player = nil
end

return SinigangPowerup