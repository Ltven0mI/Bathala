local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sprites = require "core.sprites"

local Throwable = require "assets.entities.throwable"
local Sfx = require "classes.sfx"

local Vase = Class{
    init = function(self, x, y)
        Throwable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -7, -12, 14, 12)
    end,
    __includes = {
        Throwable
    },
    damage=3,
    drag=4,
    velocityCutoff = 48,
    throwSpeed = 256,
    img = Sprites.new("assets/images/tiles/vase.png"),
    imgBroken = Sprites.new("assets/images/tiles/vase_broken.png", {isGround=true}),
    smashSfx = Sfx("assets/sound/vase_smash.mp3"),

    tag = "pickupable",
}

function Vase:smash()
    Throwable.smash(self)
    Signal.emit("vase-smashed", self.pos.x, self.pos.y)
end

return Vase