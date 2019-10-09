local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Throwable = require "assets.entities.throwable"
local Sfx = require "classes.sfx"

local Vase = Class{
    init = function(self, x, y)
        Throwable.init(self, x, y, 16, 16)
        self.isThrown = false
        self.isSmashed = false
        self.velocity = Vector(0, 0)
    end,
    __includes = {
        Throwable
    },
    damage=3,
    drag=4,
    velocityCutoff = 48,
    throwSpeed = 256,
    img = love.graphics.newImage("assets/tiles/vase.png"),
    imgBroken = love.graphics.newImage("assets/tiles/vase_broken.png"),
    smashSfx = Sfx("assets/sound/vase_smash.mp3"),

    type = "pickupable",
}

function Vase:smash()
    Throwable.smash(self)
    Signal.emit("vase-smashed", self.pos.x, self.pos.y)
end

return Vase