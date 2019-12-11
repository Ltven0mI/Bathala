local Class = require "hump.class"
local Maf = require "core.maf"

local Animations = require "core.animations"

local Entity = require "classes.entity"

local VFX = Class{
    __includes = {Entity},
    init = function(self, x, y, z, rotation)
        Entity.init(self, x, y, z)

        self.animation = Animations.new(self.animationName, self.animationTag)
        self.animation:onLoop(self.destroy, self)

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite:setTexture(self.spriteCanvas)

        self.rot = rotation or 0
    end,

    animationName=nil,
    animationTag=nil,

    spriteMeshFile=nil,
    spriteImgFile=nil,
    spriteIsTransparent=false,

    tags = {"vfx"}
}

function VFX:update(dt)
    self.animation:update(dt)
end

function VFX:redrawSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function VFX:draw()
    self:redrawSpriteCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function VFX:destroy()
    self.map:unregisterEntity(self)
end

return VFX