local Class = require "hump.class"
local Vector = require "hump.vector"

local Tiles = require "core.tiles"
local Animations = require "core.animations"

local ColliderBox = require "classes.collider_box"

local Pickupable = require "classes.pickupable"

local BarricadeItem = Class{
    __includes = {Pickupable},
    init = function(self, x, y, z)
        Pickupable.init(self, x, y, z, 16, 16, 16)
        self.collider = ColliderBox(self, -8, -8, 16, 16)

        self.animation = Animations.new("barricade_item", "idle")
        self.spriteCanvas = love.graphics.newCanvas(self.animation:getWidth(), self.animation:getHeight())
        self.sprite:setTexture(self.spriteCanvas)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile=nil,
    spriteIsTransparent=true,

    heldSpriteMeshFile="assets/meshes/billboard16x16.obj",
    heldSpriteImgFile="assets/images/powerups/barricade_item_held.png",
    heldSpriteIsTransparent=false,

    tags = {"item-barricade", "pickupable"}
}

function BarricadeItem:update(dt)
    self.animation:update(dt)
end

function BarricadeItem:redrawSpriteCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.spriteCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(0, 0)

    love.graphics.pop()
end

function BarricadeItem:draw()
    self:redrawSpriteCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function BarricadeItem:use(map, x, y, dir)
    -- TODO: Reimplement Barricade placing
    -- local gridX, gridY = map:worldToGridPos(x, y)
    -- local tileInPlace = map:getTileAt(gridX, gridY, 2)
    -- if tileInPlace then return end

    -- local tileInstance = Tiles.new("barricade", map, gridX, gridY, 2, self.player.lookDirection)
    -- map:setTileAt(tileInstance, gridX, gridY, 2)

    -- self.player.heldItem = nil
    -- self.player = nil
end

return BarricadeItem