local Class = require "hump.class"
local SmartTile = require "classes.smarttile"
local SpriteLoader = require "core.spriteloader"
local PathUtil = require "AssetBundle.PathUtil"

local _local = {}

local Carpet = Class{
    init = function(self, map, x, y, layerId)
        SmartTile.init(self, map, x, y, layerId)
    end,
    __includes={ SmartTile },

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/tiles/carpet/base.png",
    spriteIsTransparent=false,

    noiseFrequency = 2,

    imagePath = "assets/images/tiles/carpet",
    imageConditions = {
        {
            imageName="base",
            neighbours={
                0, 0, 0,
                0, 1, 0,
                0, 0, 0
            }
        },
        {
            imageName="edge_left",
            neighbours={
                0, 0, 0,
                2, 1, 0,
                0, 0, 0
            }
        },
        {
            imageName="edge_top",
            neighbours={
                0, 2, 0,
                0, 1, 0,
                0, 0, 0
            }
        },
        {
            imageName="edge_right",
            neighbours={
                0, 0, 0,
                0, 1, 2,
                0, 0, 0
            }
        },
        {
            imageName="edge_bottom",
            neighbours={
                0, 0, 0,
                0, 1, 0,
                0, 2, 0
            }
        },

        {
            imageName="outer_topleft",
            neighbours={
                0, 2, 0,
                2, 1, 0,
                0, 0, 0
            }
        },
        {
            imageName="outer_topright",
            neighbours={
                0, 2, 0,
                0, 1, 2,
                0, 0, 0
            }
        },
        {
            imageName="outer_bottomright",
            neighbours={
                0, 0, 0,
                0, 1, 2,
                0, 2, 0
            }
        },
        {
            imageName="outer_bottomleft",
            neighbours={
                0, 0, 0,
                2, 1, 0,
                0, 2, 0
            }
        },

        {
            imageName="inner_topleft",
            neighbours={
                2, 1, 0,
                1, 1, 0,
                0, 0, 0
            }
        },
        {
            imageName="inner_topright",
            neighbours={
                0, 1, 2,
                0, 1, 1,
                0, 0, 0
            }
        },
        {
            imageName="inner_bottomright",
            neighbours={
                0, 0, 0,
                0, 1, 1,
                0, 1, 2
            }
        },
        {
            imageName="inner_bottomleft",
            neighbours={
                0, 0, 0,
                1, 1, 0,
                2, 1, 0
            }
        },
    }
}

return Carpet