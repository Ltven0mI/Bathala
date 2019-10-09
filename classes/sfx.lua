local Class = require "hump.class"
local Vector = require "hump.vector"

local Sfx = Class{
    init = function(self, path)
        self.soundData = love.sound.newSoundData(path)
        self.source = love.audio.newQueueableSource(self.soundData:getSampleRate(), self.soundData:getBitDepth(), self.soundData:getChannelCount(), 8)
        self.play = function(self)
            self.source:queue(self.soundData)
            self.source:play()
        end
    end,
}

return Sfx