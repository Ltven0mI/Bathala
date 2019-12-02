local Class = require "hump.class"
local Maf = require "core.maf"
local Util3D = require "core.util3d"

local SpriteLoader = require "core.spriteloader"

-- local DepthManager = require "core.depthmanager"

local ColliderBox = require "classes.collider_box"

local Tile = Class{
    init = function(self, map, gridX, gridY, gridZ)
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.pos = Maf.vector(map:gridToWorldPos(gridX, gridY, gridZ))
        self.collider = ColliderBox(self, 0, 0, map.tileSize, map.tileSize)
        self.map = map
        self.sprite = SpriteLoader.loadFromOBJ("assets/meshes/tile_ground.obj", "assets/images/missing_texture.png", false)
    end,
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
    -- local imgH = self.img.image:getHeight()
    -- local worldX, worldY = self.map:gridToWorldPos(self.gridX, self.gridY, 1)
    -- local depth = self.map:getDepthAtWorldPos(worldX + self.offsetX, worldY + self.offsetY + imgH, (self.layerId - 1) + self.layerHeight)

    love.graphics.setColor(1, 1, 1, 1)
    self.sprite:draw(self.pos.x + self.offsetX, self.pos.y + self.offsetY, self.pos.z + self.offsetZ)
end

return Tile