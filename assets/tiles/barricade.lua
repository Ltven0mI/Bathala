local Class = require "hump.class"
local Tile = require "classes.tile"

local ColliderBox = require "classes.collider_box"

local Barricade = Class{
    init = function(self, map, x, y, layerId, rotation)
        Tile.init(self, map, x, y, layerId)
        self.rotation = rotation
        self.img = self.images[rotation] or self.img
        if rotation == "up" then
            self.collider = ColliderBox(self, 0, 0, 16, 7)
        elseif rotation == "down" then
            self.collider = ColliderBox(self, 0, 9, 16, 7)
        elseif rotation == "left" then
            self.collider = ColliderBox(self, 0, 0, 4, 16)
        elseif rotation == "right" then
            self.collider = ColliderBox(self, 12, 0, 4, 16)
        end

        self.health = 10
    end,
    __includes={ Tile },
    images={
        up=love.graphics.newImage("assets/images/tiles/barricade_top.png"),
        down=love.graphics.newImage("assets/images/tiles/barricade_bottom.png"),
        left=love.graphics.newImage("assets/images/tiles/barricade_left.png"),
        right=love.graphics.newImage("assets/images/tiles/barricade_right.png"),
    },
    img = love.graphics.newImage("assets/images/tiles/barricade_top.png"),
    isSolid = true,
    maxHealth = 10,
    tag = "barricade",
}

function Barricade:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y)
    if self.health < self.maxHealth then
        local barX, barY = self.pos.x, self.pos.y + 6
        love.graphics.setColor(0.2, 0.05, 0.05, 1)
        love.graphics.rectangle("fill", barX, barY, 16, 3)
        love.graphics.setColor(162/256, 31/256, 31/256, 1)
        love.graphics.rectangle("fill", barX + 1, barY + 1, 14 * (self.health / self.maxHealth), 1)
    end
    -- self.collider:drawWireframe()
end

function Barricade:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health == 0 then
        self.map:setTileAt(nil, self.gridX, self.gridY, self.layerId)
    end
end

return Barricade