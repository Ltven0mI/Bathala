local Class = require "hump.class"
local AssetBundle = require "AssetBundle"
local Vector = require "hump.vector"

local Entities = require "core.entities"
local Tiles = require "core.tiles"
local DepthManager = require "core.depthmanager"

local PathUtil = require "AssetBundle.PathUtil"

local ColliderBox = require "classes.collider_box"

local _local = {}

local Map = Class{
    init = function(self, mapData)
        self.width = mapData.width
        self.height = mapData.height
        self.depth = mapData.depth

        self.grid = _local.generateGrid(self, mapData)
        self:updateTileNeighbours()

        self.entities = {}
        _local.createAndRegisterEntities(self, mapData)

        self.hasStarted = false
    end,
    collisionLayer=2,
    tileSize=16,

    LAYER_COLLISION=2
}

-- [[ Util Functions ]] --

function Map:worldToGridPos(x, y, z)
    return math.floor(x / self.tileSize) + 1, math.floor(y / self.tileSize) + 2, math.floor(z / self.tileSize) + 1
end

function Map:gridToWorldPos(x, y, z)
    return ((x-1)+0.5) * self.tileSize, ((y-1)-1) * self.tileSize, ((z-1) + 0.5) * self.tileSize
end

function Map:getTileNeighboursAt(x, y, z)
    local neighbourGrid = {}
    for x2=-1, 1 do
        neighbourGrid[x2] = {}
        for z2=-1, 1 do
            neighbourGrid[x2][z2] = self:getTileAt(x + x2, y, z + z2)
        end
    end
    return neighbourGrid
end
-- \\ End Util Functions // --


-- [[ Callback Functions ]] --

function Map:update(dt)
    if not self.hasStarted then
        self.hasStarted = true
        for _, entity in ipairs(self.entities) do
            entity:start()
        end
    end
    
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
end

function Map:draw()
    love.graphics.setColor(1, 1, 1, 1)

    for x=1, self.width do
        for y=1, self.height do
            for z=1, self.depth do
                local tileData = self.grid[x][y][z]
                if tileData ~= nil then
                    tileData:draw()
                end
            end
        end
    end

    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end
-- \\ End Callback Functions // --


-- [[ Tile Functions ]] --

function Map:checkIsOutsideMap(x, y, z)
    return (x < 1 or y < 1 or z < 1) or (x > self.width or y > self.height or z > self.depth)
end

function Map:getTileAt(x, y, z)
    if self:checkIsOutsideMap(x, y, z) then
        return nil
    end
    return self.grid[x][y][z]
end

function Map:setTileAt(tileData, x, y, z)
    if self:checkIsOutsideMap(x, y, z)  then
        return nil
    end
    self.grid[x][y][z] = tileData
    self:updateTileNeighboursAround(x, y, z)
end

function Map:getTilesInCollider(collider, tagStr)
    -- TODO: Reimplement this
    return nil
    -- if tagStr and type(tagStr) ~= "table" then
    --     tagStr = {tagStr}
    -- end

    -- local results = {}
    -- local worldX, worldY = collider:getWorldCoords()
    -- local minGridX, minGridY = self:worldToGridPos(worldX, worldY)
    -- local maxGridX, maxGridY = self:worldToGridPos(worldX + collider.w, worldY + collider.h)

    -- -- print(minGridX, minGridY, maxGridX, maxGridY)

    -- for x=minGridX, maxGridX do
    --     for y=minGridY, maxGridY do
    --         local tileData = self:getTileAt(x, y, self.collisionLayer)
    --         if tileData and tileData.isSolid and tileData.collider and (tileData.tag == nil or tagStr == nil or _hasEntityGotTag(tileData, tagStr)) and
    --             collider:intersect(ColliderBox({pos=Vector(self:gridToWorldPos(x, y))},
    --                 tileData.collider.x, tileData.collider.y, tileData.collider.w, tileData.collider.h)) then
    --                 table.insert(results, tileData)
    --         end
    --     end
    -- end

    -- return #results > 0 and results or nil
end
-- \\ End Tile Functions // --


-- [[ Entity Functions ]] --

function Map:registerEntity(entity)
    table.insert(self.entities, entity)
    entity:onRegistered(self)
end

function Map:unregisterEntity(entity)
    for k, e in ipairs(self.entities) do
        if e == entity then
            table.remove(self.entities, k)
            break
        end
    end
    entity:onUnregistered()
end


-- TODO: Combine Entity.type and Entity.tag
local function _hasEntityGotTag(entity, tagStr)
    for _, tag in ipairs(tagStr) do
        if entity.tag == tag then
            return true
        end
    end
end

function Map:findEntityOfType(typeStr)
    for _, entity in ipairs(self.entities) do
        if entity.type == typeStr then
            return entity
        end
    end
    return nil
end

function Map:getEntityAt(x, y, typeStr)
    for _, entity in ipairs(self.entities) do
        if typeStr == nil or entity.type == typeStr then
            if entity.collider:intersectPoint(x, y) then
                return entity
            end
        end
    end
    return nil
end

function Map:getAllEntitiesWithTag(tagStr)
    if tagStr and type(tagStr) ~= "table" then
        tagStr = {tagStr}
    end

    local results = {}
    for _, entity in ipairs(self.entities) do
        if tagStr == nil or _hasEntityGotTag(entity, tagStr) then
            table.insert(results, entity)
        end
    end

    return (#results > 0) and results or nil
end

function Map:getEntitiesInCollider(collider, tagStr)
    if tagStr and type(tagStr) ~= "table" then
        tagStr = {tagStr}
    end
    local results = {}
    for _, entity in ipairs(self.entities) do
        if entity.collider and tagStr == nil or _hasEntityGotTag(entity, tagStr) then
            if collider:intersect(entity.collider) then
                table.insert(results, entity)
            end
        end
    end
    return #results > 0 and results or nil
end
-- \\ End Entity Functions // --


-- [[ Core Functions ]] --
function Map:updateTileNeighboursAround(x, y, z)
    for x2=x-1, x+1 do
        for z2=z-1, z+1 do
            self:updateTileNeighboursAt(x2, y, z2)
        end
    end
end

function Map:updateTileNeighboursAt(x, y, z)
    local tileData = self:getTileAt(x, y, z)
    if tileData and tileData.onNeighboursChanged then
        tileData:onNeighboursChanged()
    end
end

function Map:updateTileNeighbours()
    for x=1, self.width do
        for y=1, self.height do
            for z=1, self.depth do
                self:updateTileNeighboursAt(x, y, z)
            end
        end
    end
end

function _local.generateGrid(map, mapData)
    local grid = {}

    for x=1, map.width do
        grid[x] = {}
        for y=1, map.height do
            grid[x][y] = {}
            for z=1, map.depth do
                local tileIndex = mapData.tileIndexGrid[x][y][z]
                local tileName = mapData.tileIndex[tileIndex]
                if tileName then
                    grid[x][y][z] = Tiles.new(tileName, map, x, y, z)
                end
            end
        end
    end

    return grid
end

function _local.createAndRegisterEntities(map, mapData)
    for _, entry in ipairs(mapData.entities) do
        map:registerEntity(Entities.new(entry.name, entry.x, entry.y, entry.z))
    end
end

function Map:expand(left, right, up, down, forward, backward)
    if left < 0 or right < 0 or up < 0 or down < 0 or forward < 0 or backward < 0 then
        return false, "All arguments must be positive!"
    end

    local newWidth = self.width + left + right
    local newHeight = self.height + up + down
    local newDepth = self.depth + forward + backward
    local newGrid = {}
    for x=1, newWidth do
        newGrid[x] = {}
        for y=1, newHeight do
            newGrid[x][y] = {}
            for z=1, newDepth do
                -- If x,y,z is outside of original grid then use nil for the new space.
                local tileData
                if (x > left and x <= newWidth - right) and
                (y > down and y <= newHeight - up) and
                (z > backward and z <= newDepth - forward) then
                    tileData = self.grid[x-left][y-down][z-backward]
                    if tileData ~= nil then
                        tileData:setGridPos(x, y, z)
                    end
                end
                newGrid[x][y][z] = tileData
            end
        end
    end

    self.width = newWidth
    self.height = newHeight
    self.depth = newDepth
    self.grid = newGrid

    return true
end

function Map:contract(left, right, up, down, forward, backward)
if left < 0 or right < 0 or up < 0 or down < 0 or forward < 0 or backward < 0 then
    return false, "All arguments must be positive!"
end

local newWidth = self.width - left - right
local newHeight = self.height - up - down
local newDepth = self.depth - forward - backward

if newWidth < 1 or newHeight < 1 or newDepth < 1 then
    return false, "Cannot contract map to be smaller than 1 in any axis"
end

local newGrid = {}
for x=1, newWidth do
    newGrid[x] = {}
    for y=1, newHeight do
        newGrid[x][y] = {}
        for z=1, newDepth do
            -- If x,y,z is outside of original grid then use nil for the new space.
            local tileData
            tileData = self.grid[x+left][y+down][z+backward]
            if tileData ~= nil then
                tileData:setGridPos(x, y, z)
            end
            newGrid[x][y][z] = tileData
        end
    end
end

self.width = newWidth
self.height = newHeight
self.depth = newDepth
self.grid = newGrid

return true
end


local function _tableToString(t, indentation)
    indentation = indentation or 0
    local result = "{\n"

    for k, v in pairs(t) do
        local kType = type(k)
        local vType = type(v)

        local keyString = ""
        if kType == "string" then
            keyString = string.format("\"%s\"", k)
        elseif kType == "number" then
            keyString = string.format("%d", k)
        else
            error(string.format("TableToString only works with 'string' or 'number' keys... Not '%s'", kType))
        end

        local valString = ""
        if vType == "string" then
            valString = string.format("\"%s\"", v)
        elseif vType == "number" then
            valString = string.format("%d", v)
        elseif vType == "table" then
            valString = _tableToString(v, indentation + 1)
        else
            error(string.format("TableToString only supports values of types 'string', 'number' and 'table'... Not '%s'", vType))
        end

        result = result .. string.format("%s[%s]=%s,\n", string.rep("  ", indentation + 1), keyString, valString)
    end

    return result .. string.rep("  ", indentation) .. "}"
end

function Map:exportMap(filePath)
    local headerPattern = [[local m = {}
m.width = %d
m.height = %d
m.depth = %d]]
    local headerString = string.format(headerPattern, self.width, self.height, self.depth)

    local tilesUsed = {}
    for x=1, self.width do
        for y=1, self.height do
            for z=1, self.depth do
                local tileData = self.grid[x][y][z]
                if tileData ~= nil then
                    if tilesUsed[tileData.__name] == nil then
                        print(tileData.__name)
                        tilesUsed[tileData.__name] = tileData
                    end
                end
            end
        end
    end

    local tile_index_to_name = {}
    local tile_name_to_index = {}

    for name, tileData in pairs(tilesUsed) do
        table.insert(tile_index_to_name, name)
        tile_name_to_index[name] = #tile_index_to_name
    end

    local tileIndexPattern = "m.tileIndex = %s"
    local tileIndexString = string.format(tileIndexPattern, _tableToString(tile_index_to_name))

    local tileIndexGrid = {}

    for x=1, self.width do
        tileIndexGrid[x] = {}
        for y=1, self.height do
            tileIndexGrid[x][y] = {}
            for z=1, self.depth do
                local index = 0
                local tileData = self.grid[x][y][z]
                if tileData ~= nil then
                    index = tile_name_to_index[tileData.__name]
                end
                tileIndexGrid[x][y][z] = index
            end
        end
    end

    -- for layerId=1, map.layerCount do
    --     decimalLayouts[layerId] = {}
    --     for x=1, map.width do
    --         decimalLayouts[layerId][x] = {}
    --         for y=1, map.height do
    --             local tileData = map.grids[layerId][x][y]
    --             if tileData == nil then
    --                 decimalLayouts[layerId][x][y] = 0
    --             else
    --                 decimalLayouts[layerId][x][y] = reverseTileIndex[tileData.name]
    --             end
    --         end
    --     end
    -- end

    local gridPattern = "m.tileIndexGrid = %s"
    local gridString = string.format(gridPattern, _tableToString(tileIndexGrid))

    local entityDataTable = {}
    for _, entity in ipairs(self.entities) do
        table.insert(entityDataTable, {name=entity.__name, x=entity.pos.x, y=entity.pos.y, z=entity.pos.z})
    end

    local entitiesPattern = "m.entities = %s"
    local entitiesString = string.format(entitiesPattern, _tableToString(entityDataTable))
    
    local footerString = "return m"

    local filePattern = "%s\n%s\n%s\n%s\n%s"
    local fileString = string.format(filePattern, headerString,
    tileIndexString, gridString, entitiesString, footerString)

    -- print(fileString)

    local root, baseName = PathUtil.split(filePath)
    local success = love.filesystem.createDirectory(root)
    if not success then
        return false, string.format("Failed to create export directory '%s'", root)
    end
    local success, err = love.filesystem.write(filePath, fileString)
    if not success then
        return false, err
    end

    return true
end

return Map