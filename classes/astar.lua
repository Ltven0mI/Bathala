local Class = require "hump.class"
local Maf = require "core.maf"

local SpriteLoader = require "core.spriteloader"

local _local = {}
local AStar = Class{
    init = function(self, map, nodeScale)
        self.map = map
        self.width = math.floor(map.width / nodeScale)
        self.depth = math.floor(map.depth / nodeScale)
        self.nodeScale = nodeScale
        self:generateNodeGrid()
    end,

    nodeSprite = SpriteLoader.createSprite("assets/meshes/billboard6x6_flat.obj", nil, false)
}

function AStar:generateNodeGrid()
    local nodeGrid = {}
    local nodeSize = self.map.tileSize * self.nodeScale
    local halfNodeSize = math.floor(nodeSize / 2)
    for x=1, self.width do
        nodeGrid[x] = {}
        for z=1, self.depth do
            -- TODO: Do cubeChecks on the map to find out what size can fit through this node
            local worldX, worldY, worldZ = (x-1) * nodeSize + halfNodeSize, halfNodeSize, (z-1) * nodeSize + halfNodeSize
            local collided, collisions = self.map:checkCube(worldX, worldY-halfNodeSize, worldZ, nodeSize, nodeSize, nodeSize, nil, nil, true)
            if not collided then
                nodeGrid[x][z] = {}
            end
        end
    end
    self.nodeGrid = nodeGrid
end

function AStar:drawNodeGrid()
    local nodeSize = self.map.tileSize * self.nodeScale
    local halfNodeSize = math.floor(nodeSize / 2)
    for x=1, self.width do
        for z=1, self.depth do
            local node = self.nodeGrid[x][z]
            if node ~= nil then
                self.nodeSprite:draw((x-1) * nodeSize + nodeSize, 1, (z-1) * nodeSize + nodeSize)
            end
        end
    end
end

return AStar