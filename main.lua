love.graphics.setDefaultFilter("nearest", "nearest")

local Gamestate = require "hump.gamestate"
local AssetBundle = require "AssetBundle"

Gamestates = {
    menu=require("gamestates.menu"),
    game=require("gamestates.game"),
    gameover=require("gamestates.gameover")
}

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Gamestates.menu)
end