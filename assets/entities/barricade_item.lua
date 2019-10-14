local Class = require "hump.class"
local Vector = require "hump.vector"

local Peachy = require "peachy"

local Tiles = require "core.tiles"
local ColliderBox = require "classes.collider_box"
local Pickupable = require "classes.pickupable"

local BarricadeItem = Class{
    init = function(self, x, y)
        Pickupable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -8, 16, 16)
        self.animation = Peachy.new("assets/images/powerups/barricade_item.json", love.graphics.newImage("assets/images/powerups/barricade_item.png"), "idle")
    end,
    __includes = {
        Pickupable
    },

    img = love.graphics.newImage("assets/images/powerups/barricade_item_held.png"),

    tag = "pickupable",
}

function BarricadeItem:update(dt)
    self.animation:update(dt)
end

function BarricadeItem:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(self.pos.x, self.pos.y, 0, 1, 1, math.floor(self.w / 2), self.h)
end

function BarricadeItem:use(map, x, y, dir)
    local gridX, gridY = map:worldToGridPos(x, y)
    local tileInPlace = map:getTileAt(gridX, gridY, 2)
    if tileInPlace then return end

    local tileInstance = Tiles.new("barricade", map, gridX, gridY, 2, self.player.lookDirection)
    map:setTileAt(tileInstance, gridX, gridY, 2)

    self.player.heldItem = nil
    self.player = nil
end

return BarricadeItem