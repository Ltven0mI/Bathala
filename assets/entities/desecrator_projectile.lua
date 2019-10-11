local Class = require "hump.class"
local Vector = require "hump.vector"

local ColliderBox = require "classes.collider_box"

local Projectile = require "assets.entities.projectile"

local DesecratorProjectile = Class{
    init = function(self, x, y, dir)
        Projectile.init(self, x, y, dir)
        self.w = 16
        self.h = 16
        self.collider = ColliderBox(self, -5, -5, 10, 10)
    end,
    __includes = {
        Projectile
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = {"player", "statue"},
    img = love.graphics.newImage("assets/images/projectiles/desecrator_projectile.png"),

    type = "projectile",
}

return DesecratorProjectile