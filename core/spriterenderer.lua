local Util3D = require "core.util3d"
local Camera = require "core.camera3d"

local m = {}

local _local = {}
_local.transparentSpriteBuffer = {}


-- Stores the sprite and args in the transparent sprite buffer
function m.storeTransparentSprite(sprite, x, y, z, color, shader)
    table.insert(_local.transparentSpriteBuffer, {sprite=sprite, x=x, y=y, z=z or 0, color=color, shader=shader})
end

-- Sorts then draws transparent sprites
-- Sprites are sorted by decending 'z'
function m.drawTransparentSprites()
    love.graphics.push("all")
    table.sort(_local.transparentSpriteBuffer, function(a, b) return (a.z > b.z) end)
    for _, entry in ipairs(_local.transparentSpriteBuffer) do
        if entry.color then love.graphics.setColor(entry.color) end
        love.graphics.setShader(entry.shader)
        m.drawSpriteDirect(entry.sprite, entry.x, entry.y, entry.z)
    end
    _local.transparentSpriteBuffer = {}
    love.graphics.pop()
end

-- Draws a sprite in the world ( does not take into account transparency )
function m.drawSpriteDirect(sprite, x, y, z)
    sprite.mesh:setTexture(sprite.texture)
    love.graphics.draw(sprite.mesh, Util3D.getTranslationTransform(x, y, z))
end

-- TODO: Take in a width and a height for the returned image
function m.renderSpriteToImage(sprite)
    local camera = Camera(0, 0, 0, 16, 32, -128, 128, 1)
    local canvas = love.graphics.newCanvas(16, 32)
    canvas:renderTo(function()
        camera:attach()
        love.graphics.setColor(1, 1, 1, 1)
        m.drawSpriteDirect(sprite, 0, -8, 0)
        camera:detach()
    end)
    return canvas
end

return m