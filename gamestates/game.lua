local Camera = require "hump.camera"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"

local game = {}

game.camera = nil
game.player = nil

local assets = AssetBundle("assets", {
    "player/player_temp.png"
})

function game:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.player = Player(assets.player.player_temp)
end

function game:leave()
    AssetBundle.unload(assets)

    self.camera = nil
    self.player = nil
end

function game:update(dt)
    self.player:update(dt)
end

function game:draw()
    self.camera:attach()

    self.player:draw()

    self.camera:detach()
end

return game