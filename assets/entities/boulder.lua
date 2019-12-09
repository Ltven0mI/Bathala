local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sfx = require "classes.sfx"

local Throwable = require "assets.entities.throwable"

local Boulder = Class{
    __includes = {Throwable},
    init = function(self, x, y, z)
        Throwable.init(self, x, y, z, 16, 16, 16)
        self.collider = ColliderBox(self, -8, -14, 16, 14)
    end,

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