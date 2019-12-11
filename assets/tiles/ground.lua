local Class = require "hump.class"
local SmartTile = require "classes.smarttile"

local Ground = Class{
    __includes={ SmartTile },
    init = function(self, map, x, y, z)
        SmartTile.init(self, map, x, y, z)
    end,

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/ground/smooth.png",
    spriteIsTransparent=false,

    noiseFrequency = 2,

    imagePath = "assets/images/tiles/ground",
    imageConditions = {
        {
            imageName="smooth",
            neighbours={
                0, 0, 0,
                0, 1, 0,
                0, 0, 0
            },
            noiseRange={min=0, max=0.6}
        },
        {
            imageName="cracked",
            neighbours={
                0, 0, 0,
                0, 1, 0,
                0, 0, 0
            },
            noiseRange={min=0.6, max=1}
        }
    }
}

return Ground