local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local Entity = require "classes.entity"

local VFX = Class{
    init = function(self, x, y, z, animation, rotation)
        Entity.init(self, x, y, z, animation:getWidth(), animation:getHeight())
        self.animation = animation
        self.animation:onLoop(self.destroy, self)

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite = Sprites.new(self.spriteCanvas, {isGround=true})

        self.rot = rotation or 0
        -- self.collider = ColliderBox(self, -7, -12, 14, 12)
    end,
    __includes = {
        Entity
    },

    rot=0,

    tag = "vfx",
}

function VFX:update(dt)
    self.animation:update(dt)
end

function VFX:updateSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    local halfW = math.floor(self.w / 2)
    local halfH = math.floor(self.h / 2)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(halfW, halfH, self.rot, 1, 1, halfW, halfH)

    love.graphics.pop()
end

function VFX:draw()
    local halfW = math.floor(self.w / 2)
    local halfH = math.floor(self.h / 2)

    self:updateSpriteCanvas()

    local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y + halfH, 2)
    local xPos = math.floor(self.pos.x - halfW)
    local yPos = math.floor(self.pos.y - halfH)

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
end

function VFX:destroy()
    self.map:unregisterEntity(self)
end

return VFX