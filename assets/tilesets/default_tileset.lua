local AssetBundle = require "AssetBundle"

local t = {}

local assets = AssetBundle("assets", {
    "tiles/carpet_left.png",
    "tiles/carpet_middle.png",
    "tiles/carpet_right.png",

    "tiles/ground_cracked.png",
    "tiles/ground_smooth.png",

    "tiles/pillar_layer1.png",
    "tiles/pillar_layer2.png",
    "tiles/pillar_layer3.png",
    "tiles/pillar_layer4.png",
    "tiles/pillar_layer5.png",
    "tiles/pillar_layer5_front.png",
})

t.tiles = {}

local function createTile(name, img, isSolid)
    t.tiles[name] = {
        name=name,
        img=img,
        isSolid=isSolid
    }
end

local function createTiles()
    createTile("carpet_left", assets.tiles.carpet_left, false)
    createTile("carpet_middle", assets.tiles.carpet_middle, false)
    createTile("carpet_right", assets.tiles.carpet_right, false)
    
    createTile("ground_cracked", assets.tiles.ground_cracked, false)
    createTile("ground_smooth", assets.tiles.ground_smooth, false)

    createTile("pillar_layer1", assets.tiles.pillar_layer1, true)
    createTile("pillar_layer2", assets.tiles.pillar_layer2, true)
    createTile("pillar_layer3", assets.tiles.pillar_layer3, true)
    createTile("pillar_layer4", assets.tiles.pillar_layer4, true)
    createTile("pillar_layer5", assets.tiles.pillar_layer5, true)
    createTile("pillar_layer5_front", assets.tiles.pillar_layer5_front, true)
end

function t.load()
    AssetBundle.load(assets)
    createTiles()
end

function t.unload()
    AssetBundle.unload(assets)
end

return t