local Class = require "hump.class"

local Map = Class{
    init = function(self, img)
        self.img = img
        self.width = img:getWidth()
        self.height = img:getHeight()
    end,
}

function Map:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local offsetX = math.floor(self.width / 2)
    local offsetY = math.floor(self.height / 2)
    love.graphics.draw(self.img, 0, 0, 0, 1, 1, offsetX, offsetY)
end

return Map