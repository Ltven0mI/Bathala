love.graphics.setDefaultFilter("nearest", "nearest")

local Gamestate = require "hump.gamestate"
local AssetBundle = require "AssetBundle"

local Entities = require "core.entities"
local Tiles = require "core.tiles"
local Animations = require "core.animations"

local Console = require "core.console"

Gamestates = {
    menu=require("gamestates.menu"),
    game=require("gamestates.game"),
    gameover=require("gamestates.gameover")
}

function love.load()
    Gamestate.registerEvents()

    Animations.loadAnimations()
    Entities.loadEntities()
    Tiles.loadTiles()

    Gamestate.switch(Gamestates.menu)

    Console.expose("set_gamestate", function(gamestateName)
        local gamestate = Gamestates[gamestateName]
        if gamestate == nil then
            return false, string.format("Unknown gamestate '%s'", gamestateName)
        end
        Gamestate.switch(gamestate)
    end)
end