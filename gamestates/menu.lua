local Gamestate = require "hump.gamestate"
local game_gamestate = require "gamestates.game"
local editor_gamestate = require "gamestates.editor"

local menu = {}

local titleScreen = love.graphics.newImage("assets/titlescreen/title_screen.png")

function menu:draw()
    love.graphics.draw(titleScreen, 0, 0, 0, 4, 4)
end

function menu:keypressed()
    Gamestate.switch(game_gamestate)
end

function menu:mousepressed(x, y, btn)
    Gamestate.switch(game_gamestate)
    -- Gamestate.switch(editor_gamestate)
end

return menu