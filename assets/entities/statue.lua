local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local Entity = require "classes.entity"

local Statue = Class{
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 32, 48)
        self.collider = ColliderBox(self, -12, -9, 24, 19)
        self.health = 60

        self.healthbarW = self.w + 2
        self.healthbarH = 4

        self.healthbarCanvas = love.graphics.newCanvas(self.healthbarW, self.healthbarH)
        self.healthbarSprite = Sprites.new(self.healthbarCanvas)
    end,
    __includes = {
        Entity
    },
    maxHealth = 60,
    aliveImg = Sprites.new("assets/images/tiles/bathala_statue.png"),
    rubbleImg = Sprites.new("assets/images/tiles/bathala_statue_rubble.png"),

    type = "statue",
    tag = "statue",
}

function Statue:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health == 0 then
        Signal.emit("statue-died", self)
    end
end

function Statue:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Statue:update(dt)

end

function Statue:redrawHealthbarCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.healthbarCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)

    local barW = self.healthbarW
    local barH = self.healthbarH

    love.graphics.setColor(0.2, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", 0, 0, barW, barH)
    love.graphics.setColor(162/256, 31/256, 31/256, 1)
    love.graphics.rectangle("fill", 1, 1, (barW-2) * (self.health / self.maxHealth), barH-2)

    love.graphics.pop()
end

-- TODO: Need to reimplement this
function Statue:draw()
    -- love.graphics.setColor(1, 1, 1, 1)
    
    -- local img = self.aliveImg
    -- if self.health == 0 then
    --     img = self.rubbleImg
    -- end

    -- local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 2)
    -- local xPos = self.pos.x - math.floor(self.w / 2)
    -- local yPos = self.pos.y - math.floor(self.h / 3) * 2

    -- img:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
    -- -- self.collider:drawWireframe()

    -- self:redrawHealthbarCanvas()
    -- local barX = self.pos.x - math.floor(self.healthbarW / 2)
    -- local barY = self.pos.y - math.floor(self.h / 3) * 2 - self.healthbarH
    -- self.healthbarSprite:draw(DepthManager.getTranslationTransform(barX, barY, depth))
end

return Statue