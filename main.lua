local Gamestate = require "hump.gamestate"
local AssetBundle = require "AssetBundle"

local gamestates = {
    menu=require("gamestates.menu"),
    game=require("gamestates.game")
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Gamestate.registerEvents()
    Gamestate.switch(gamestates.menu)
end