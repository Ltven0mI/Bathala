local Class = require "hump.class"
local Maf = require "core.maf"

local ColliderBox = require "classes.collider_box"

local Entity = Class{
    init = function(self, x, y, z, width, height, depth)
        self.collider = ColliderBox(self, 0, 0, width, height)
        self.pos = Maf.vector(x, y, z)
        self.width = width
        self.height = height
        self.depth = depth
        self.map = nil
    end,
    __includes = {
    },
    tags={}
}

-- [[ Util Functions ]] --

function Entity:setPos(x, y, z)
    self.pos.x = x
    self.pos.y = y
    self.pos.z = z
end

-- Returns true if self has the specified tag and false if not
function Entity:hasTag(tag)
    for _, otherTag in ipairs(self.tags) do
        if tag == otherTag then
            return true
        end
    end
    return false
end
-- \\ End Util Functions // --

-- Called when the game first starts
function Entity:start()

end

-- Called every frame before draw is called
function Entity:update(dt)

end

-- Called every frame after update is called
function Entity:draw()

end

-- Called when an entity is registered to a map
function Entity:onRegistered(map)
    self.map = map
end

-- Called when an entity is unregistered from a map
function Entity:onUnregistered()
    self.map = nil
end

return Entity