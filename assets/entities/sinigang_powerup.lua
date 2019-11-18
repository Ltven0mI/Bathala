local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Peachy = require "peachy"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local Pickupable = require "classes.pickupable"

local SinigangPowerup = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -16, 16, 16)
        self.animation = Peachy.new("assets/images/powerups/sinigang_powerup.json", love.graphics.newImage("assets/images/powerups/sinigang_powerup.png"), "idle")

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite = Sprites.new(self.spriteCanvas)
    end,
    __includes = {
        Pickupable
    },
    healAmount = 20,
    img = Sprites.new("assets/images/powerups/sinigang_powerup_held.png"),

    tag = "pickupable",
}

function SinigangPowerup:update(dt)
    self.animation:update(dt)
end

function SinigangPowerup:updateSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function SinigangPowerup:draw()
    local imgW = self.animation:getWidth()
    local halfImgW = math.floor(imgW / 2)

    self:updateSpriteCanvas()

    local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 2)
    local xPos = self.pos.x - halfImgW
    local yPos = self.pos.y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
end

function SinigangPowerup:use(map, x, y, dir)
    Signal.emit("statue-heal", self.healAmount)
    self.player.heldItem = nil
    self.player = nil
end

return SinigangPowerup