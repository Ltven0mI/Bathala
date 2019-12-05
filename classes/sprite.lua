local Class = require "hump.class"
local SpriteRenderer = require "core.spriterenderer"

local Sprite = Class{
    init = function(self, drawable, isTransparent)
        self.drawable = drawable
        self.isTransparent = isTransparent
    end,
    __includes = {
    }
}

function Sprite:draw(x, y, z)
    if self.isTransparent then
        local color = {love.graphics.getColor()}
        local shader = love.graphics.getShader()
        SpriteRenderer.storeTransparentSprite(self, x, y, z, color, shader)
    else
        SpriteRenderer.drawSpriteDirect(self, x, y, z)
    end
end

return Sprite