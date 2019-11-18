local Class = require "hump.class"
local Tile = require "classes.tile"

local Sprites = require "core.sprites"
local DepthManager = require "core.depthmanager"

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

        self.healthbarW = 14
        self.healthbarH = 4

        self.healthbarCanvas = love.graphics.newCanvas(self.healthbarW, self.healthbarH)
        self.healthbarSprite = Sprites.new(self.healthbarCanvas)

        self.health = 10
    end,
    __includes={ Tile },
    images={
        up=Sprites.new("assets/images/tiles/barricade_top.png"),
        down=Sprites.new("assets/images/tiles/barricade_bottom.png"),
        left=Sprites.new("assets/images/tiles/barricade_left.png"),
        right=Sprites.new("assets/images/tiles/barricade_right.png"),
    },
    img = Sprites.new("assets/images/tiles/barricade_top.png"),
    isSolid = true,
    maxHealth = 10,
    tag = "barricade",
}

function Barricade:redrawHealthbarCanvas()
    love.graphics.push("all")
    love.graphics.reset()

    love.graphics.setCanvas(self.healthbarCanvas)

    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)

    local barW = self.healthbarW
    local barH = self.healthbarH

    love.graphics.setColor(0.2, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", 0, 0, barW, barH)
    love.graphics.setColor(162/256, 31/256, 31/256, 1)
    love.graphics.rectangle("fill", 1, 1, (barW-2) * (self.health / self.maxHealth), barH-2)

    love.graphics.pop()
end

function Barricade:draw()
    Tile.draw(self)
    if self.health < self.maxHealth then
        self:redrawHealthbarCanvas()

        local worldX, worldY = self.map:gridToWorldPos(self.gridX, self.gridY, 1)
        local depth = self.map:getDepthAtWorldPos(worldX, worldY, self.layerId)
        
        local barX = self.pos.x
        local barY = self.pos.y + math.floor(self.map.tileSize / 2) - math.floor(self.healthbarH / 2)
        self.healthbarSprite:draw(DepthManager.getTranslationTransform(barX, barY, depth))
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