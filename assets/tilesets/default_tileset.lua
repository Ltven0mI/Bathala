local AssetBundle = require "AssetBundle"
local Entities = require "core.entities"

local t = {}

local assets = AssetBundle("assets", {
    "images/tiles/carpet_left.png",
    "images/tiles/carpet_middle.png",
    "images/tiles/carpet_right.png",

    "images/tiles/ground_cracked.png",
    "images/tiles/ground_smooth.png",

    "images/tiles/pillar_base1.png",
    "images/tiles/pillar_base2.png",
    "images/tiles/pillar_layer1.png",
    "images/tiles/pillar_layer2.png",
    "images/tiles/pillar_layer3.png",
    "images/tiles/pillar_layer4.png",
    "images/tiles/pillar_layer5.png",
    "images/tiles/pillar_layer5_front.png",

    "images/tiles/statue_base_topleft.png",
    "images/tiles/statue_base_topright.png",
    "images/tiles/statue_base_bottomleft.png",
    "images/tiles/statue_base_bottomright.png",

    "images/tiles/bathala_statue.png",
    "images/tiles/bathala_statue_rubble.png",

    -- Icons --
    icon_desecrator="images/desecrator/desecrator_static.png",
    icon_statue="images/tiles/bathala_statue.png",
    icon_spawner="images/tiles/spawner.png",
    icon_vase="images/tiles/vase.png",
    icon_player_spawn="images/tiles/player_spawn.png"
})

t.tiles = {}

local function createTile(name, img, isSolid, collider, icon)
    collider = collider or {}
    collider.x = collider.x or 0
    collider.y = collider.y or 0
    collider.w = collider.w or 16
    collider.h = collider.h or 16
    icon = icon or img
    t.tiles[name] = {
        name=name,
        img=img,
        isSolid=isSolid,
        collider=collider,
        icon=icon
    }
end

local function createTiles()
    createTile("carpet_left", assets.images.tiles.carpet_left, false)
    createTile("carpet_middle", assets.images.tiles.carpet_middle, false)
    createTile("carpet_right", assets.images.tiles.carpet_right, false)
    
    createTile("ground_cracked", assets.images.tiles.ground_cracked, false)
    createTile("ground_smooth", assets.images.tiles.ground_smooth, false)

    createTile("pillar_base1", assets.images.tiles.pillar_base1, true)
    createTile("pillar_base2", assets.images.tiles.pillar_base2, true)
    createTile("pillar_layer1", assets.images.tiles.pillar_layer1, true)
    createTile("pillar_layer2", assets.images.tiles.pillar_layer2, true)
    createTile("pillar_layer3", assets.images.tiles.pillar_layer3, true)
    createTile("pillar_layer4", assets.images.tiles.pillar_layer4, true)
    createTile("pillar_layer5", assets.images.tiles.pillar_layer5, true)
    createTile("pillar_layer5_front", assets.images.tiles.pillar_layer5_front, true)

    createTile("statue_base_topleft", assets.images.tiles.statue_base_topleft, true, {x=4, y=7, w=12, h=9})
    createTile("statue_base_topright", assets.images.tiles.statue_base_topright, true, {x=0, y=7, w=12, h=9})
    createTile("statue_base_bottomleft", assets.images.tiles.statue_base_bottomleft, true, {x=4, y=0, w=12, h=10})
    createTile("statue_base_bottomright", assets.images.tiles.statue_base_bottomright, true, {x=0, y=0, w=12, h=10})

    createTile("bathala_statue", assets.images.tiles.bathala_statue, false)
    createTile("bathala_statue_rubble", assets.images.tiles.bathala_statue_rubble, false)
end

t.entities = {}

local function createEntity(entity, icon)
    t.entities[entity.__name] = {
        name=entity.__name,
        entity=entity,
        icon=icon
    }
end

local function createEntities()
    createEntity(Entities.get("enemy"), assets.icon_desecrator)
    createEntity(Entities.get("statue"), assets.icon_statue)
    createEntity(Entities.get("spawner"), assets.icon_spawner)
    createEntity(Entities.get("vase"), assets.icon_vase)
    createEntity(Entities.get("player_spawn"), assets.icon_player_spawn)
end

function t.load()
    AssetBundle.load(assets)
    createTiles()
    createEntities()
end

function t.unload()
    AssetBundle.unload(assets)
end

return t