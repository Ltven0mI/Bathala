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
        self.direction = Maf.vector(0, 0, 0)
        self.velocity = Maf.vector(0, 0, 0)

        self.throwProgress = 0

        self.brokenSprite = SpriteLoader.loadFromOBJ(self.brokenSpriteMeshFile, self.brokenSpriteImgFile, self.brokenSpriteIsTransparent)

        if self.smashSFXName then
            self.smashSFX = Sfx(self.smashSFXName)
        end
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile="assets/meshes/billboard16x16_flat_float.obj",
    brokenSpriteImgFile="assets/images/missing_texture.png",
    brokenSpriteIsTransparent=false,

    damage=3,

    minProgressAfterSmash = 0.6, -- throwProgress will be set to max(throwProgress, minProgressAfterSmash) when smash() is called
    throwProgressMultiplier = 2, -- how quickly throwProgress increases
    throwSpeed = 200, -- the initial speed when thrown
    gravity = 148, -- the gravity at the end of the throw

    timeToLiveAfterSmash = 10, -- number of seconds after smash() before being destroyed
    
    throwCurve = love.math.newBezierCurve(
        0.0, 1,
        0.25, 0.9,
        0.5, 0.8,
        0.75, 0.25,
        1.0, 0
    ),
    smashSFXName = nil,

    isColliderSolid = false,

    tags = {"throwable", "pickupable"},
}

function Throwable:update(dt)
    if self.isThrown then
        self.throwProgress = self.throwProgress + dt * self.throwProgressMultiplier
        if self.throwProgress > 1 then
            self.throwProgress = 1
        end

        local _, curveValue = self.throwCurve:evaluate(self.throwProgress)
        self.velocity = (self.direction * self.throwSpeed * curveValue + Maf.vector(0, -1, 0) * self.gravity * (1-curveValue))

        local collisions = self:move((self.velocity * dt):unpack())
        if not self.isSmashed and collisions and #collisions > 0 then
            for _, collision in ipairs(collisions) do
                if collision.other.hasTag and collision.other:hasTag("enemy") and collision.other.takeDamage then
                    collision.other:takeDamage(self.damage)
                end
            end
            self:smash()
        end
    end

    if self.isSmashed then
        self.timeToLiveAfterSmash = self.timeToLiveAfterSmash - dt
        if self.timeToLiveAfterSmash <= 0 then
            self:destroy()
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
    self:putDown(x, y+self.player.height, z, map)
    self.isThrown = true
    self.throwProgress = 0
    self.direction = dir
end

function Throwable:smash()
    self.tags = {"throwable-broken"}
    self.isSmashed = true
    if self.throwProgress < self.minProgressAfterSmash then
        self.throwProgress = self.minProgressAfterSmash
    end
    if self.smashSFX then
        self.smashSFX:play()
    end
end

return Throwable