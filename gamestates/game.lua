local Camera = require "hump.camera"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"
local Map = require "classes.map"

local game = {}

game.camera = nil
game.player = nil
game.map = nil

local assets = AssetBundle("assets", {
    "player/player_temp.png",
    "maps/level1.lua"
})

function game:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.map = Map(assets.maps.level1)
    
    self.player = Player(assets.player.player_temp)
    self.player:setMap(self.map)
end

function game:leave()
    AssetBundle.unload(assets)

    self.camera = nil
    self.player = nil
    self.map = nil
end

function game:update(dt)
    self.player:update(dt)

    local playerX, playerY = self.player.pos:unpack()

    local screenW, screenH = love.graphics.getDimensions()

    local viewPortW = math.floor(screenW / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)

    local mapW, mapH = self.map.width * self.map.tileSize, self.map.height * self.map.tileSize

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX))
    local lockY = math.max(halfViewH, math.min(mapH - halfViewH, playerY))

    self.camera:lockPosition(lockX, lockY)
end

function game:draw()
    self.camera:attach()

    self.map:draw()
    self.player:draw()

    self.camera:detach()
end

return game