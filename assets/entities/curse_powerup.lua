local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Peachy = require "peachy"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local UseItem = require "assets.entities.use_item"
local ColliderBox = require "classes.collider_box"

local CurseProjectile = require "assets.entities.curse_projectile"

local CursePowerup = Class{
    init = function(self, x, y, z)
        UseItem.init(self, x, y, z, 16, 16)
        self.collider = ColliderBox(self, -8, -16, 16, 16)
        self.animation = Peachy.new("assets/images/powerups/curse_powerup.json", love.graphics.newImage("assets/images/powerups/curse_powerup.png"), "idle")

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite = Sprites.new(self.spriteCanvas)
    end,
    __includes = {
        UseItem
    },

    isUsable=true,

    hudIcon = love.graphics.newImage("assets/images/ui/curse_powerup_icon.png"),

    tag = "pickupable",
}

function CursePowerup:update(dt)
    self.animation:update(dt)
end

function CursePowerup:updateSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function CursePowerup:draw()
    local imgW = self.animation:getWidth()
    local halfImgW = math.floor(imgW / 2)

    self:updateSpriteCanvas()

    local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 2)
    local xPos = self.pos.x - halfImgW
    local yPos = self.pos.y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
    -- self.collider:drawWireframe()
end

function CursePowerup:use(map, x, y, dir)
    local instance = CurseProjectile(x, y, dir)
    self.player.map:registerEntity(instance)
end

return CursePowerup