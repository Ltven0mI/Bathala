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
    "map/temp.png"
})

function game:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.player = Player(assets.player.player_temp)
    self.map = Map(assets.map.temp)
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

    local halfMapW, halfMapH = math.floor(self.map.width / 2), math.floor(self.map.height / 2)

    local lockX = math.max(-halfMapW + halfViewW, math.min(halfMapW - halfViewW, playerX))
    local lockY = math.max(-halfMapH + halfViewH, math.min(halfMapH - halfViewH, playerY))

    self.camera:lockPosition(lockX, lockY)
end

function game:draw()
    self.camera:attach()

    self.map:draw()
    self.player:draw()

    self.camera:detach()
end

return game