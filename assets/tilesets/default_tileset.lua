local AssetBundle = require "AssetBundle"

local t = {}

local assets = AssetBundle("assets", {
    "tiles/carpet_left.png",
    "tiles/carpet_middle.png",
    "tiles/carpet_right.png",

    "tiles/ground_cracked.png",
    "tiles/ground_smooth.png",

    "tiles/pillar_base1.png",
    "tiles/pillar_base2.png",
    "tiles/pillar_layer1.png",
    "tiles/pillar_layer2.png",
    "tiles/pillar_layer3.png",
    "tiles/pillar_layer4.png",
    "tiles/pillar_layer5.png",
    "tiles/pillar_layer5_front.png",

    "tiles/statue_base_topleft.png",
    "tiles/statue_base_topright.png",
    "tiles/statue_base_bottomleft.png",
    "tiles/statue_base_bottomright.png",

    "tiles/bathala_statue.png",
    "tiles/bathala_statue_rubble.png",

    -- Icons --
    icon_desecrator="desecrator/desecrator_temp.png",
    icon_statue="tiles/bathala_statue.png",
    icon_spawner="tiles/spawner.png",
    icon_vase="tiles/vase.png",
    icon_player_spawn="tiles/player_spawn.png",

    -- Entities --
    "entities/enemy.lua",
    "entities/statue.lua",
    "entities/spawner.lua",
    "entities/vase.lua",
    "entities/player_spawn.lua",
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
    createTile("carpet_left", assets.tiles.carpet_left, false)
    createTile("carpet_middle", assets.tiles.carpet_middle, false)
    createTile("carpet_right", assets.tiles.carpet_right, false)
    
    createTile("ground_cracked", assets.tiles.ground_cracked, false)
    createTile("ground_smooth", assets.tiles.ground_smooth, false)

    createTile("pillar_base1", assets.tiles.pillar_base1, true)
    createTile("pillar_base2", assets.tiles.pillar_base2, true)
    createTile("pillar_layer1", assets.tiles.pillar_layer1, true)
    createTile("pillar_layer2", assets.tiles.pillar_layer2, true)
    createTile("pillar_layer3", assets.tiles.pillar_layer3, true)
    createTile("pillar_layer4", assets.tiles.pillar_layer4, true)
    createTile("pillar_layer5", assets.tiles.pillar_layer5, true)
    createTile("pillar_layer5_front", assets.tiles.pillar_layer5_front, true)

    createTile("statue_base_topleft", assets.tiles.statue_base_topleft, true, {x=4, y=7, w=12, h=9})
    createTile("statue_base_topright", assets.tiles.statue_base_topright, true, {x=0, y=7, w=12, h=9})
    createTile("statue_base_bottomleft", assets.tiles.statue_base_bottomleft, true, {x=4, y=0, w=12, h=10})
    createTile("statue_base_bottomright", assets.tiles.statue_base_bottomright, true, {x=0, y=0, w=12, h=10})

    createTile("bathala_statue", assets.tiles.bathala_statue, false)
    createTile("bathala_statue_rubble", assets.tiles.bathala_statue_rubble, false)
end

t.entities = {}

local function createEntity(name, entity, icon)
    entity.name = name
    t.entities[name] = {
        name=name,
        entity=entity,
        icon=icon
    }
end

local function createEntities()
    createEntity("enemy", assets.entities.enemy, assets.icon_desecrator)
    createEntity("statue", assets.entities.statue, assets.icon_statue)
    createEntity("spawner", assets.entities.spawner, assets.icon_spawner)
    createEntity("vase", assets.entities.vase, assets.icon_vase)
    createEntity("player_spawn", assets.entities.player_spawn, assets.icon_player_spawn)
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