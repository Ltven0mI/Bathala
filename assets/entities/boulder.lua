local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local Sfx = require "classes.sfx"

local Throwable = require "assets.entities.throwable"

local Boulder = Class{
    __includes = {Throwable},
    init = function(self, x, y, z)
        Throwable.init(self, x, y, z)
    end,

    width = 16,
    height = 14,
    depth = 16,

    colliderOffsetX = 0,
    colliderOffsetY = 7,
    colliderOffsetZ = 0,
    
    isColliderSolid = true,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/tiles/boulder.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile="assets/meshes/billboard16x16_flat.obj",
    brokenSpriteImgFile="assets/images/tiles/boulder_broken.png",
    brokenSpriteIsTransparent=false,

    smashSfx = Sfx("assets/sound/vase_smash.mp3"),

    tags = {"boulder", "throwable", "pickupable"}
}

return Boulder