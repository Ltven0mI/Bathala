local Class = require "hump.class"
local Maf = require "core.maf"
local SpriteLoader = require "core.spriteloader"

local ColliderBox = require "classes.collider_box"

local Tile = Class{
    init = function(self, map, gridX, gridY, gridZ)
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.pos = Maf.vector(map:gridToWorldPos(gridX, gridY, gridZ))
        self.collider = ColliderBox(self, 0, 0, map.tileSize, map.tileSize)
        self.map = map
        self.sprite = SpriteLoader.loadFromOBJ(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)
    end,
    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    isSolid = false,
    layerHeight = 1,
    offsetX = 0,
    offsetY = 0,
    offsetZ = 0
}

function Tile:start()

end

function Tile:update(dt)

end

function Tile:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos.x + self.offsetX, self.pos.y + self.offsetY, self.pos.z + self.offsetZ)
end

return Tile