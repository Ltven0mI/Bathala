love.graphics.setDefaultFilter("nearest", "nearest")

local Gamestate = require "hump.gamestate"
local AssetBundle = require "AssetBundle"

local Entities = require "core.entities"

Gamestates = {
    menu=require("gamestates.menu"),
    game=require("gamestates.game"),
    gameover=require("gamestates.gameover")
}

function love.load()
    Gamestate.registerEvents()

    Entities.loadEntities()

    Gamestate.switch(Gamestates.menu)
end