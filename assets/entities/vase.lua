local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sfx = require "classes.sfx"

local Throwable = require "assets.entities.throwable"

local Vase = Class{
    __includes = {Throwable},
    init = function(self, x, y, z)
        Throwable.init(self, x, y, z)
    end,

    width = 14,
    height = 12,
    depth = 10,

    colliderOffsetX = 0,
    colliderOffsetY = 6,
    colliderOffsetZ = 5,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/tiles/vase.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile=nil,
    brokenSpriteImgFile="assets/images/tiles/vase_broken.png",
    brokenSpriteIsTransparent=false,

    smashSFXName = "assets/sound/vase_smash.mp3",

    tags = {"vase", "throwable", "pickupable"}
}

function Vase:smash()
    Throwable.smash(self)
    Signal.emit("vase-smashed", self.pos.x, 0, self.pos.z)
end

return Vase