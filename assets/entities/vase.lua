local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sfx = require "classes.sfx"

local Throwable = require "assets.entities.throwable"

local Vase = Class{
    __includes = {Throwable},
    init = function(self, x, y, z)
        Throwable.init(self, x, y, z, 16, 16, 16)
        self.collider = ColliderBox(self, -7, -12, 14, 12)
    end,

    spriteMeshFile="assets/meshes/billboard16x16.obj",
    spriteImgFile="assets/images/tiles/vase.png",
    spriteIsTransparent=false,

    brokenSpriteMeshFile="assets/meshes/billboard16x16_flat.obj",
    brokenSpriteImgFile="assets/images/tiles/vase_broken.png",
    brokenSpriteIsTransparent=false,

    smashSfx = Sfx("assets/sound/vase_smash.mp3"),

    tags = {"vase", "throwable", "pickupable"}
}

function Vase:smash()
    Throwable.smash(self)
    Signal.emit("vase-smashed", self.pos.x, self.pos.y, self.pos.z)
end

return Vase