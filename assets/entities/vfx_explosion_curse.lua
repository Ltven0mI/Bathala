local Class = require "hump.class"
local Maf = require "core.maf"

local Util3D = require "core.util3d"

local VFX = require "assets.entities.vfx"

local VFX_Explosion_Curse = Class{
    __includes = {VFX},
    init = function(self, x, y, z, rotation)
        VFX.init(self, x, y, z, rotation)
        self.rot = rotation or 0
    end,

    animationName="magic_explosion",
    animationTag="default",

    spriteMeshFile=Util3D.generateMesh(26, 0, 26),
    spriteImgFile=nil,
    spriteIsTransparent=true,

    tags = {"vfx-explosion-curse", "vfx"}
}

return VFX_Explosion_Curse