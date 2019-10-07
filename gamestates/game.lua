local Camera = require "hump.camera"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"
local Map = require "classes.map"

local game = {}

game.camera = nil
game.player = nil
game.tileset = nil
game.map = nil

local assets = AssetBundle("assets", {
    maps={
        level1="mapExport.lua"
    },
    "player/player_temp.png",
    "entities/enemy.lua",
    "tilesets/default_tileset.lua"
})

function game:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.tileset = assets.tilesets.default_tileset
    self.tileset.load()

    self.map = Map(assets.maps.level1, self.tileset)
    self.map:generateGrid()
    
    self.player = Player(assets.player.player_temp, 0, 0, 10, 16)
    self.player:setMap(self.map)

    local enemy = assets.entities.enemy(8*16, 12*16, 16, 16)
    self.map:registerEntity(enemy)

    enemy:setTarget(8 * 16, 4 * 16)
end

function game:leave()
    AssetBundle.unload(assets)

    self.camera = nil
    self.player = nil

    self.tileset.unload()
    self.tileset = nil

    self.map = nil
end

function game:update(dt)
    self.map:update(dt)
    self.player:update(dt)

    local playerX, playerY = self.player.pos:unpack()

    local screenW, screenH = love.graphics.getDimensions()

    local viewPortW = math.floor(screenW / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)

    local mapW, mapH = self.map.width * self.map.tileSize, self.map.height * self.map.tileSize

    local halfPlayerW, halfPlayerH = math.floor(self.player.w / 2), math.floor(self.player.h / 2)

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX + halfPlayerW))
    local lockY = math.max(halfViewH, math.min(mapH - halfViewH, playerY + halfPlayerH))

    self.camera:lockPosition(lockX, lockY)
end

function game:draw()
    self.camera:attach()

    self.map:draw(1, 2)
    self.map:drawEntities()
    self.player:draw()
    self.map:draw(3)

    self.camera:detach()

    -- local screenW, screenH = love.graphics.getDimensions()
    -- love.graphics.line(0, math.floor(screenH / 2), screenW, math.floor(screenH / 2))
    -- love.graphics.line(math.floor(screenW / 2), 0, math.floor(screenW / 2), screenH)
end

return game