local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"
local SpriteLoader = require "core.spriteloader"

local Sfx = require "classes.sfx"

local Pickupable = require "assets.entities.pickupable"

local Throwable = Class{
    __includes = {Pickupable},
    init = function(self, x, y, z)
        Pickupable.init(self, x, y, z)
        self.isThrown = false
        self.isSmashed = false
        self.velocity = Maf.vector(0, 0, 0)

        self.brokenSprite = SpriteLoader.loadFromOBJ(self.brokenSpriteMeshFile, self.brokenSpriteImgFile, self.brokenSpriteIsTransparent)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile="assets/meshes/billboard16x16_flat.obj",
    brokenSpriteImgFile="assets/images/missing_texture.png",
    brokenSpriteIsTransparent=false,

    damage=3,
    drag=4,
    velocityCutoff = 48,
    throwSpeed = 256,
    smashSfx = nil,

    tags = {"throwable", "pickupable"},
}

function Throwable:update(dt)
    if self.isThrown then
        -- Apply velocity
        self.pos = self.pos + self.velocity * dt
        
        -- Double the drag if it is smashed
        local drag = (not self.isSmashed and self.drag or self.drag * 2)
        self.velocity = self.velocity - (self.velocity * drag * dt)

        -- Hulk Smash!
        if not self.isSmashed and self.velocity:len() < self.velocityCutoff then
            self:smash()
        end

        -- TODO: Reimplement Collisions on Throwable
        if not self.isSmashed and self.map then
            -- local hitEntities = self.map:getEntitiesInCollider(self.collider, "enemy")
            -- if hitEntities then
            --     hitEntities[1]:takeDamage(self.damage)
            --     self:smash()
            -- else
            --     local hitTiles = self.map:getTilesInCollider(self.collider)
            --     if hitTiles then
            --         self:smash()
            --     end
            -- end
        end
    end
end

function Throwable:draw()
    local currentSprite = self.isSmashed and self.brokenSprite or self.sprite
    love.graphics.setColor(1, 1, 1, 1)
    currentSprite:draw(self.pos:unpack())
end

function Throwable:canPickUp()
    return not self.isThrown
end

function Throwable:use(map, x, y, z, dir)
    self:putDown(x, y, z, map)
    self.isThrown = true
    self.velocity = dir * self.throwSpeed
end

function Throwable:smash()
    self.tags = {"throwable-broken"}
    self.isSmashed = true
    self.isColliderSolid = false
    if self.smashSfx then
        self.smashSfx:play()
    end
end

return Throwable