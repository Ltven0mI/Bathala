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
        Collider.init(self, worldX, worldY, worldZ, self.width, self.height, self.depth)
        
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.map = map
        self.sprite = SpriteLoader.loadFromOBJ(self.spriteMeshFile, self.spriteImgFile, self.spriteIsTransparent)

        if self.extraColliders then
            self.extraColliderInstances = {}
            for _, colliderData in ipairs(self.extraColliders) do
                local x, y, z, w, h, d = unpack(colliderData)
                local newCollider = Collider(self.pos.x, self.pos.y, self.pos.z, w, h, d)
                newCollider.colliderOffsetX = x
                newCollider.colliderOffsetY = y
                newCollider.colliderOffsetZ = z
                newCollider.isColliderSolid = true
                table.insert(self.extraColliderInstances, newCollider)
            end
        end
    end,

    width = 16,
    height = 16,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 8,
    colliderOffsetZ = 0,
    
    isColliderSolid = true,

    extraColliders = nil,

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,
}

-- [[ Util Functions ]] --

-- Returns true if self has the specified tag and false if not
function Tile:hasTag(tag)
    if self.tags == nil then
        return false
    end
    for _, otherTag in ipairs(self.tags) do
        if tag == otherTag then
            return true
        end
    end
    return false
end
-- \\ End Util Functions // --

function Tile:setPos(x, y, z)
    Collider:setPos(x, y, z)
    if self.extraColliderInstances then
        for i, childCollider in ipairs(self.extraColliderInstances) do
            local colliderData = self.extraColliders[i]
            childCollider:setPos(x, y, z)
        end
    end
end

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

function Tile:onRegistered(map)
    Collider.onRegistered(self, map)
    if self.extraColliderInstances then
        for _, childCollider in ipairs(self.extraColliderInstances) do
            map:registerCollider(childCollider)
        end
    end
end

function Tile:onUnregistered()
    Collider.onUnregistered(self)
    if self.extraColliderInstances then
        for _, childCollider in ipairs(self.extraColliderInstances) do
            map:unregisterCollider(childCollider)
        end
    end
end

return Tile