local Class = require "hump.class"
local Maf = require "core.maf"
local SpriteLoader = require "core.spriteloader"
local SpriteRenderer = require "core.spriterenderer"

local ColliderBox = require "classes.collider_box"

local Collider = require "classes.collider"

local Entity = Class{
    __includes={Collider},
    init = function(self, x, y, z)
        Collider.init(self, x, y, z, self.width, self.height, self.depth)
        self.sprite = SpriteLoader.createSprite(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)
    end,

    width = 16,
    height = 16,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 0,
    colliderOffsetZ = 0,

    colliderIsSolid = false,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    tags={}
}

-- [[ Util Functions ]] --

-- Returns true if self has the specified tag and false if not
function Entity:hasTag(tag)
    for _, otherTag in ipairs(self.tags) do
        if tag == otherTag then
            return true
        end
    end
    return false
end
-- \\ End Util Functions // --

-- Called when the game first starts
function Entity:start()

end

-- Called every frame before draw is called
function Entity:update(dt)

end

-- Called every frame after update is called
function Entity:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos:unpack())
end

function Entity:onLoaded()
    self.icon = self:renderToImage()
end

function Entity:renderToImage()
    local sprite = self.sprite or SpriteLoader.createSprite(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)
    return SpriteRenderer.renderSpriteToImage(sprite)
end

return Entity