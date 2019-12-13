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

    width = 14,
    height = 14,
    depth = 12,

    colliderOffsetX = 0,
    colliderOffsetY = 7,
    colliderOffsetZ = 6,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/tiles/boulder.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile=nil,
    brokenSpriteImgFile="assets/images/tiles/boulder_broken.png",
    brokenSpriteIsTransparent=false,

    smashSFXName = "assets/sound/vase_smash.mp3",

    tags = {"boulder", "throwable", "pickupable"}
}

return Boulder