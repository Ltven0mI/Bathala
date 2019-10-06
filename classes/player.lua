local Class = require "hump.class"
local Vector = require "hump.vector"

local player = Class{
    init = function(self, img)
        self.pos = Vector(0, 0)
        self.moveProgress = 0
        self.img = img
    end,
    speed = 64
}

function player:update(dt)
    local w = love.keyboard.isDown("w")
    local a = love.keyboard.isDown("a")
    local s = love.keyboard.isDown("s")
    local d = love.keyboard.isDown("d")

    local deltaX = (a and -1 or 0) + (d and 1 or 0)
    local deltaY = (w and -1 or 0) + (s and 1 or 0)
    local inputDelta = Vector(deltaX, deltaY):normalized()

    self.moveProgress = self.moveProgress + inputDelta:len() * self.speed * dt
    local flooredProgress = self.moveProgress --math.floor(self.moveProgress)
    self.moveProgress = self.moveProgress - flooredProgress

    self.pos = self.pos + inputDelta * flooredProgress
end

function player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

return player