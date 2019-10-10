local Class = require "hump.class"
local Vector = require "hump.vector"

local Projectile = require "assets.entities.projectile"

local DesecratorProjectile = Class{
    init = function(self, x, y, dir)
        Projectile.init(self, x, y, dir)
    end,
    __includes = {
        Projectile
    },
    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = {"player", "statue"},
    img = love.graphics.newImage("assets/desecrator/desecrator_projectile.png"),

    type = "projectile",
}

return DesecratorProjectile