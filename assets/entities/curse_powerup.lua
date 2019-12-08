local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local Peachy = require "peachy"

local ColliderBox = require "classes.collider_box"

local CurseProjectile = require "assets.entities.curse_projectile"

local UseItem = require "assets.entities.use_item"

local CursePowerup = Class{
    __includes = {UseItem},
    init = function(self, x, y, z)
        UseItem.init(self, x, y, z, 16, 16, 16)
        self.collider = ColliderBox(self, -8, -16, 16, 16)

        self.animation = Peachy.new("assets/images/powerups/curse_powerup.json", love.graphics.newImage("assets/images/powerups/curse_powerup.png"), "idle")
        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite:setTexture(self.spriteCanvas)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile=nil,
    spriteIsTransparent=true,

    isUsable=true,

    hudIcon = love.graphics.newImage("assets/images/ui/curse_powerup_icon.png"),

    tags = {"powerup-curse", "useitem", "pickupable"}
}

function CursePowerup:update(dt)
    self.animation:update(dt)
end

function CursePowerup:redrawSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function CursePowerup:draw()
    self:redrawSpriteCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function CursePowerup:use(map, x, y, z, dir)
    local instance = CurseProjectile(x, y, z, dir)
    self.player.map:registerEntity(instance)
end

return CursePowerup