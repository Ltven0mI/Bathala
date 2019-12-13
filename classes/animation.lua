local Class = require "hump.class"
local Peachy = require "peachy"

local Animation = Class{
    __includes = {},
    init = function(self, initialTag)
        self.peach = Peachy.new(self.jsonData, self.spriteSheet, initialTag)
    end,
}

local proxies = {
    "setTag",
    "setFrame",
    "draw",
    "update",
    "nextFrame",
    "call_onLoop",
    "pause",
    "play",
    "stop",
    "onLoop",
    "togglePlay",
    "getWidth",
    "getHeight",
    "_pingpongBounce",
    "_initializeFrames",
    "_initializeTags",
    "_checkImageSize"
}

for _, funcName in ipairs(proxies) do
    Animation[funcName] = function(self, ...)
        return self.peach[funcName](self.peach, ...)
    end
end

return Animation