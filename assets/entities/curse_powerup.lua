local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Peachy = require "lib.peachy"

local UseItem = require "assets.entities.use_item"
local ColliderBox = require "classes.collider_box"

local CurseProjectile = require "assets.entities.curse_projectile"

local CursePowerup = Class{
    init = function(self, x, y)
        UseItem.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -16, 16, 16)
        self.animation = Peachy.new("assets/powerups/curse_powerup.json", love.graphics.newImage("assets/powerups/curse_powerup.png"), "idle")
    end,
    __includes = {
        UseItem
    },

    isUsable=true,

    icon = love.graphics.newImage("assets/images/ui/curse_powerup_icon.png"),

    tag = "pickupable",
}

function CursePowerup:update(dt)
    self.animation:update(dt)
end

function CursePowerup:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(self.pos.x, self.pos.y, 0, 1, 1, math.floor(self.w / 2), self.h)
    -- self.collider:drawWireframe()
end

function CursePowerup:use(map, x, y, dir)
    local instance = CurseProjectile(x, y, dir)
    self.player.map:registerEntity(instance)
end

return CursePowerup