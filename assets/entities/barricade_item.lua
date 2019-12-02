local Class = require "hump.class"
local Vector = require "hump.vector"

local Peachy = require "peachy"
local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

local Tiles = require "core.tiles"
local ColliderBox = require "classes.collider_box"
local Pickupable = require "classes.pickupable"

local BarricadeItem = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -8, 16, 16)
        self.animation = Peachy.new("assets/images/powerups/barricade_item.json", love.graphics.newImage("assets/images/powerups/barricade_item.png"), "idle")

        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite = Sprites.new(self.spriteCanvas)
    end,
    __includes = {
        Pickupable
    },

    img = Sprites.new("assets/images/powerups/barricade_item_held.png"),

    tag = "pickupable",
}

function BarricadeItem:update(dt)
    self.animation:update(dt)
end

function BarricadeItem:updateSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function BarricadeItem:draw()
    local imgW = self.animation:getWidth()
    local halfImgW = math.floor(imgW / 2)

    self:updateSpriteCanvas()

    local depth = self.map:getDepthAtWorldPos(self.pos.x, self.pos.y, 2)
    local xPos = self.pos.x - halfImgW
    local yPos = self.pos.y - self.h

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(DepthManager.getTranslationTransform(xPos, yPos, depth))
end

function BarricadeItem:use(map, x, y, dir)
    -- TODO: Need to reimplement this
    -- local gridX, gridY = map:worldToGridPos(x, y)
    -- local tileInPlace = map:getTileAt(gridX, gridY, 2)
    -- if tileInPlace then return end

    -- local tileInstance = Tiles.new("barricade", map, gridX, gridY, 2, self.player.lookDirection)
    -- map:setTileAt(tileInstance, gridX, gridY, 2)

    -- self.player.heldItem = nil
    -- self.player = nil
end

return BarricadeItem