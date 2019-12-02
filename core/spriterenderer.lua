local Util3D = require "core.util3d"

local m = {}

local _local = {}
_local.transparentSpriteBuffer = {}


-- Stores the sprite and args in the transparent sprite buffer
function m.storeTransparentSprite(sprite, x, y, z)
    table.insert(_local.transparentSpriteBuffer, {sprite=sprite, x=x, y=y, z=z or 0})
end

-- Sorts then draws transparent sprites
-- Sprites are sorted by decending 'z'
function m.drawTransparentSprites()
    table.sort(_local.transparentSpriteBuffer, function(a, b) return (a.z > b.z) end)
    for _, entry in ipairs(_local.transparentSpriteBuffer) do
        m.drawSpriteDirect(entry.sprite, entry.x, entry.y, entry.z)
    end
    _local.transparentSpriteBuffer = {}
end

-- Draws a sprite in the world ( does not take into account transparency )
function m.drawSpriteDirect(sprite, x, y, z)
    love.graphics.draw(sprite.drawable, Util3D.getTranslationTransform(x, y, z))
end

return m