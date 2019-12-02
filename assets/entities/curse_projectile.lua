local Class = require "hump.class"
local Vector = require "hump.vector"

local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local Projectile = require "assets.entities.projectile"

local CurseProjectile = Class{
    init = function(self, x, y, z, dir)
        Projectile.init(self, x, y, z, dir)
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
    img = Sprites.new("assets/images/projectiles/curse_projectile.png"),

    type = "projectile",
}

function CurseProjectile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local rot = -(self.dir:toPolar().x) + math.pi / 2
    local halfW, halfH = math.floor(self.w / 2), math.floor(self.h / 2)
    -- love.graphics.draw(self.img, self.pos.x, self.pos.y, rot, 1, 1, self.w, halfH)

    local depth = self:getDepth()
    local xPos = self.pos.x - self.w
    local yPos = self.pos.y - halfH

    local transform = DepthManager.getTranslationTransform(self.pos.x, self.pos.y, depth):rotate(rot):translate(-self.w, -halfH)

    love.graphics.setColor(1, 1, 1, 1)
    self.img:draw(transform)
    -- self.collider:drawWireframe()
end

return CurseProjectile