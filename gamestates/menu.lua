local Gamestate = require "hump.gamestate"
local game_gamestate = require "gamestates.game"
local editor_gamestate = require "gamestates.editor"

local menu = {}

function menu:draw()
    love.graphics.rectangle("line", 20, 20, 300, 30)
    love.graphics.print("Start Game!", 30, 30)
end

function menu:mousepressed(x, y, btn)
    -- Gamestate.switch(game_gamestate)
    Gamestate.switch(editor_gamestate)
end

return menu