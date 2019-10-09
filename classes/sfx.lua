local Class = require "hump.class"
local Vector = require "hump.vector"

local Sfx = Class{
    init = function(self, path)
        self.soundData = love.sound.newSoundData(path)
        self.source1 = love.audio.newQueueableSource(self.soundData:getSampleRate(), self.soundData:getBitDepth(), self.soundData:getChannelCount(), 8)
        self.source2 = love.audio.newQueueableSource(self.soundData:getSampleRate(), self.soundData:getBitDepth(), self.soundData:getChannelCount(), 8)
        self.play = function(self)
            local source = self.source1
            if self.source1:getFreeBufferCount() < self.source2:getFreeBufferCount() then
                source = self.source2
            end
            source:queue(self.soundData)
            source:play()
        end
    end,
}

return Sfx