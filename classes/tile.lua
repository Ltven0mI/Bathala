local Class = require "hump.class"
local Maf = require "core.maf"
local SpriteLoader = require "core.spriteloader"
local SpriteRenderer = require "core.spriterenderer"

local ColliderBox = require "classes.collider_box"
local Collider = require "classes.collider"

local Tile = Class{
    __includes={Collider},
    init = function(self, map, gridX, gridY, gridZ)
        local worldX, worldY, worldZ = map:gridToWorldPos(gridX, gridY, gridZ)
        Collider.init(self, worldX, worldY, worldZ, map.tileSize, map.tileSize, map.tileSize)
        
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.map = map
        self.sprite = SpriteLoader.loadFromOBJ(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)
    end,
    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    isSolid = false,
    layerHeight = 1,

    colliderOffsetY = 8,
    isColliderSolid = true
}

function Tile:setGridPos(x, y, z)
    self.gridX = x
    self.gridY = y
    self.gridZ = z
    self:setPos(self.map:gridToWorldPos(x, y, z))
end

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos.x, self.pos.y, self.pos.z)
end

function Tile:onLoaded()
    self.icon = self:renderToImage()
end

function Tile:renderToImage()
    local sprite = self.sprite or SpriteLoader.loadFromOBJ(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)
    return SpriteRenderer.renderSpriteToImage(sprite)
end

return Tile