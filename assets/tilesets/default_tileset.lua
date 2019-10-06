local AssetBundle = require "AssetBundle"

local t = {}

local assets = AssetBundle("assets", {
    "tiles/carpet_left.png",
    "tiles/carpet_middle.png",
    "tiles/carpet_right.png",
    "tiles/pillar_layer1.png",
    "tiles/pillar_layer2.png",
    "tiles/pillar_layer3.png",
    "tiles/pillar_layer4.png",
    "tiles/pillar_layer5.png",
})

t.tiles = {}

local function createTiles()
    t.tiles["carpet_left"] = {
        img = assets.tiles.carpet_left,
        isSolid = false
    }
    
    t.tiles["carpet_middle"] = {
        img = assets.tiles.carpet_middle,
        isSolid = false
    }
    
    t.tiles["carpet_right"] = {
        img = assets.tiles.carpet_right,
        isSolid = false
    }
    
    t.tiles["pillar_layer1"] = {
        img = assets.tiles.pillar_layer1,
        isSolid = true
    }
    t.tiles["pillar_layer2"] = {
        img = assets.tiles.pillar_layer2,
        isSolid = true
    }
    t.tiles["pillar_layer3"] = {
        img = assets.tiles.pillar_layer3,
        isSolid = true
    }
    t.tiles["pillar_layer4"] = {
        img = assets.tiles.pillar_layer4,
        isSolid = true
    }
    t.tiles["pillar_layer5"] = {
        img = assets.tiles.pillar_layer5,
        isSolid = true
    }
end

function t.load()
    AssetBundle.load(assets)
    createTiles()
end

function t.unload()
    AssetBundle.unload(assets)
end

return t