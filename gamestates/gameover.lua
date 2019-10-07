local Gamestate = require "hump.gamestate"

local Gameover = {}

function Gameover:enter(from)
    self.from = from
end

function Gameover:leave()
    self.from = nil
end

function Gameover:draw()
    self.from:draw()
    love.graphics.setColor(0, 0, 0, 0.6)
    local screenW, screenH = love.graphics.getDimensions()
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Game Over")
end

function Gameover:mousepressed(x, y, btn)
    self.from:leave()
    Gamestate.switch(Gamestates.menu)
end

return Gameover