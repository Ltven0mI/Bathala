local Class = require "hump.class"
local Maf = require "core.maf"
local Signal = require "hump.signal"
local SpriteLoader = require "core.spriteloader"
local Util3D = require "core.util3d"

local Entity = require "classes.entity"

local Statue = Class{
    __includes = {Entity},
    init = function(self, x, y, z)
        Entity.init(self, x, y, z, 24, 37, 24)
        self.health = 60

        self.healthbarW = self.width + 2
        self.healthbarH = 4

        self.healthbarCanvas = love.graphics.newCanvas(self.healthbarW, self.healthbarH)
        local healthBarMesh = Util3D.generateMesh(self.healthbarW, self.healthbarH, 0)
        self.healthbarSprite = SpriteLoader.createSprite(healthBarMesh, self.healthbarCanvas, false)

        self.figureSprite = SpriteLoader.createSprite(self.figureSpriteMeshFile,
        self.figureSpriteImgFile, self.figureSpriteIsTransparent)
    end,

    width = 24,
    height = 37,
    depth = 24,

    colliderOffsetX = 0,
    colliderOffsetY = 18.5,
    colliderOffsetZ = 0,
    
    isColliderSolid = true,

    spriteMeshFile="assets/meshes/statue_base.obj",
    spriteImgFile="assets/images/entities/statue_base.png",
    spriteIsTransparent=false,

    figureSpriteMeshFile="assets/meshes/statue_figure.obj",
    figureSpriteImgFile="assets/images/entities/statue_bathala.png",
    figureSpriteIsTransparent=false,

    rubbleImage=love.graphics.newImage("assets/images/entities/statue_bathala_rubble.png"),

    maxHealth = 60,
    -- aliveImg = Sprites.new("assets/images/tiles/bathala_statue.png"),
    -- rubbleImg = Sprites.new("assets/images/tiles/bathala_statue_rubble.png"),

    tags = {"statue"},
}

function Statue:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health == 0 then
        self:onDeath()
        Signal.emit("statue-died", self)
    end
end

function Statue:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Statue:update(dt)

end

function Statue:redrawHealthbarCanvas()
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

function Statue:draw()
    local img = self.aliveImg
    if self.health == 0 then
        img = self.rubbleImg
    end

    self:redrawHealthbarCanvas()
    
    local barX = self.pos.x
    local barY = self.pos.y + self.height + math.floor(self.healthbarH / 2) + 1
    local barZ = self.pos.z
    self.healthbarSprite:draw(barX, barY, barZ)

    self.sprite:draw(self.pos:unpack())
    self.figureSprite:draw(self.pos.x, self.pos.y + 5, self.pos.z)
end

function Statue:onDeath()
    self.figureSprite:setTexture(self.rubbleImage)
end

return Statue