local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local ColliderBox = require "classes.collider_box"
local Sprites = require "core.sprites"

local Throwable = require "assets.entities.throwable"
local Sfx = require "classes.sfx"

local Boulder = Class{
    init = function(self, x, y)
        Throwable.init(self, x, y, 16, 16)
        self.collider = ColliderBox(self, -8, -14, 16, 14)
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
    img = Sprites.new("assets/images/tiles/boulder.png"),
    imgBroken = Sprites.new("assets/images/tiles/boulder_broken.png", {isGround=true}),
    smashSfx = Sfx("assets/sound/vase_smash.mp3"),

    tag = "pickupable",
}

return Boulder