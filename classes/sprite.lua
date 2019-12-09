local Class = require "hump.class"
local SpriteRenderer = require "core.spriterenderer"

local Sprite = Class{
    __includes = {},
    init = function(self, mesh, texture, isTransparent)
        self.mesh = mesh
        self.texture = texture
        self.isTransparent = isTransparent
    end,
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

function Sprite:setTexture(texture)
    self.texture = texture
end

return Sprite