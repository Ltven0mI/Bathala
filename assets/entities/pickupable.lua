local Class = require "hump.class"
local Vector = require "hump.vector"
local SpriteLoader = require "core.spriteloader"

local Entity = require "classes.entity"

local Pickupable = Class{
    __includes = {Entity},
    init = function(self, x, y, z, width, height, depth)
        Entity.init(self, x, y, z, width, height, depth)
        self.player = nil
        if self.heldSpriteMeshFile ~= nil then
            self.heldSprite = SpriteLoader.createSprite(self.heldSpriteMeshFile,
            self.heldSpriteImgFile, self.heldSpriteIsTransparent)
        else
            self.heldSprite = self.sprite
        end
    end,

    heldSpriteMeshFile=nil,
    heldSpriteImgFile=nil,
    heldSpriteIsTransparent=false,

    tags = {"pickupable"},
}

function Pickupable:drawHeld(x, y, z)
    love.graphics.setColor(1, 1, 1, 1)
    self.heldSprite:draw(x, y, z)
end

function Pickupable:canPickUp()
    return true
end

function Pickupable:use(map, x, y, z, dir)

end

function Pickupable:pickup(player)
    self.map:unregisterEntity(self)
    self.player = player
    self.player.heldItem = self
end

function Pickupable:putDown(x, y, z, map)
    self.pos.x = x
    self.pos.y = y
    self.pos.z = z
    
    map:registerEntity(self)
    self.player.heldItem = nil
    self.player = nil
end

return Pickupable