local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local Animations = require "core.animations"
local Entities = require "core.entities"

local ColliderBox = require "classes.collider_box"

local Pickupable = require "assets.entities.pickupable"

local SinigangPowerup = Class{
    __includes = {Pickupable},
    init = function(self, x, y, z)
        Pickupable.init(self, x, y, z)

        self.animation = Animations.new("sinigang_powerup", "idle")
        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite:setTexture(self.spriteCanvas)
    end,

    width = 16,
    height = 16,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 8,
    colliderOffsetZ = 0,
    
    isColliderSolid = false,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile=nil,
    spriteIsTransparent=true,

    heldSpriteMeshFile="assets/meshes/billboard16x16.obj",
    heldSpriteImgFile="assets/images/powerups/sinigang_powerup_held.png",
    heldSpriteIsTransparent=false,

    healAmount = 20,

    tags = {"powerup-sinigang", "pickupable"}
}

function SinigangPowerup:update(dt)
    self.animation:update(dt)
end

function SinigangPowerup:redrawSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function SinigangPowerup:draw()
    self:redrawSpriteCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function SinigangPowerup:use(map, x, y, z, dir)
    local statue = map:findEntityWithTag("statue")
    if statue then
        if statue.health < statue.maxHealth then
            statue:heal(self.healAmount)
            self.player.heldItem = nil
            self.player = nil
        end
    end
end

return SinigangPowerup