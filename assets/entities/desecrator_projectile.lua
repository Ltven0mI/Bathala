local Class = require "hump.class"

local Util3D = require "core.util3d"

local Projectile = require "assets.entities.projectile"

local DesecratorProjectile = Class{
    __includes = {Projectile},
    init = function(self, x, y, z, dir)
        Projectile.init(self, x, y, z, dir)
    end,

    width = 10,
    height = 2,
    depth = 6,

    colliderOffsetX = 0,
    colliderOffsetY = 1,
    colliderOffsetZ = 0,
    
    isColliderSolid = false,

    spriteMeshFile=Util3D.generateMesh(10, 0, 6),
    spriteImgFile="assets/images/projectiles/desecrator_projectile.png",
    spriteIsTransparent=false,

    vfxName="vfx_explosion_curse",

    damage = 1,
    speed = 64,
    timeToLive = 3,
    damageMask = {"player", "statue", "barricade"},

    tags = {"projectile-desecrator", "projectile"}
}

return DesecratorProjectile