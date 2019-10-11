local Class = require "hump.class"
local Vector = require "hump.vector"

local ColliderBox = require "classes.collider_box"

local Projectile = require "assets.entities.projectile"

local CurseProjectile = Class{
    init = function(self, x, y, dir)
        Projectile.init(self, x, y, dir)
        self.w = 16
        self.h = 5
        self.collider = ColliderBox(self, -2.5, -2.5, 5, 5)
    end,
    __includes = {
        Projectile
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = "enemy",
    img = love.graphics.newImage("assets/powerups/curse_projectile.png"),

    type = "projectile",
}

function CurseProjectile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local rot = -(self.dir:toPolar().x) + math.pi / 2
    local halfW, halfH = math.floor(self.w / 2), math.floor(self.h / 2)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, rot, 1, 1, self.w, halfH)
end

return CurseProjectile