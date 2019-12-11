local Class = require "hump.class"

local Util3D = require "core.util3d"

local Projectile = require "assets.entities.projectile"

local CurseProjectile = Class{
    __includes = {Projectile},
    init = function(self, x, y, z, dir)
        Projectile.init(self, x, y, z, dir)
    end,

    width = 5,
    height = 0,
    depth = 5,

    colliderOffsetX = 0,
    colliderOffsetY = 0,
    colliderOffsetZ = 0,
    
    isColliderSolid = false,

    spriteMeshFile=Util3D.generateMesh(16, 0, 5),
    spriteImgFile="assets/images/projectiles/curse_projectile.png",
    spriteIsTransparent=false,

    vfxName="vfx_explosion_curse",

    damage = 1,
    speed = 64,
    timeToLive = 3,
    tagMask = "enemy",

    tags = {"projectile-curse", "projectile"}
}

return CurseProjectile