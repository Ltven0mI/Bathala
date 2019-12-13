local Class = require "hump.class"
local AssetBundle = require "AssetBundle"
local Vector = require "hump.vector"

local Entities = require "core.entities"
local Tiles = require "core.tiles"

local PathUtil = require "AssetBundle.PathUtil"

local Bump = require "libs.bump-3dpd"

local _local = {}

local Map = Class{
    init = function(self, mapData)
        self.width = mapData.width
        self.height = mapData.height
        self.depth = mapData.depth

        self.bumpWorld = Bump.newWorld(self.tileSize)

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

    -- self:doCollisionPass(dt)
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
    local lastTile = self.grid[x][y][z]
    if lastTile then
        self:unregisterCollider(lastTile)
    end
    self.grid[x][y][z] = tileData
    if tileData then
        self:registerCollider(tileData)
    end
    self:updateTileNeighboursAround(x, y, z)
end
-- \\ End Tile Functions // --


-- [[ Entity Functions ]] --

function Map:registerEntity(entity)
    if entity == nil then
        error("Attempted to register a nil entity to map!", 2)
    end
    table.insert(self.entities, entity)
    self:registerCollider(entity)
end


function Map:unregisterEntity(entity)
    if entity == nil then
        error("Attempted to unregister a nil entity!", 2)
    end
    for k, e in ipairs(self.entities) do
        if e == entity then
            table.remove(self.entities, k)
            break
        end
    end
    self:unregisterCollider(entity)
end

function _local.doesEntityMatchTags(entity, tags, requirement)
    for _, tag in ipairs(tags) do
        local doesHaveTag = entity:hasTag(tag)
        if requirement == "none" and doesHaveTag then
            return false
        elseif requirement == "any" and doesHaveTag then
            return true
        elseif requirement == "all" and not doesHaveTag then
            return false
        end
    end

    if requirement == "none" then
        return true
    elseif requirement == "any" then
        return false
    elseif requirement == "all" then
        return true
    end
end

--- Finds the first entity matching a single or multiple tags.
-- @param tag The tag to search for. Can be a single tag or a table of tags.
-- @param requirement How strict are the tags. Can be "none" so entity must have none of the specified tags, "any" so entity can have any of the specified tags or "all" so entity must have all of the specified tags. Defaults to "all".
-- @return entity, or nil if no entity was found.
function Map:findEntityWithTag(tag, requirement)
    local tags = tag
    if type(tag) ~= "table" then tags = {tag} end
    requirement = requirement or "all"

    for _, entity in ipairs(self.entities) do
        if _local.doesEntityMatchTags(entity, tags, requirement) then
            return entity
        end
    end

    return nil
end

--- Finds all entities matching a single or multiple tags.
-- @param tag The tag to search for. Can be a single tag or a table of tags.
-- @param[opt] requirement How strict are the tags. Can be "none" so entity must have none of the specified tags, "any" so entity can have any of the specified tags or "all" so entity must have all of the specified tags. Defaults to "all".
-- @return table containing found entities, or nil if no entities were found.
function Map:findEntitiesWithTag(tag, requirement)
    local tags = tag
    if type(tag) ~= "table" then tags = {tag} end
    requirement = requirement or "all"

    local results = {}
    for _, entity in ipairs(self.entities) do
        if _local.doesEntityMatchTags(tags, requirement) then
            table.insert(results, entity)
        end
    end

    return (#results > 0) and results or nil
end
-- \\ End Entity Functions // --


-- [[ Collider Functions ]] --

--- Checks for any colliders that intersect the passed collider
-- @param collider The collider to check collisions for
-- @param[opt] tag An optional tag to check for
-- @param[optchain] requirement requirement How strict are the tags. Can be "none" so colliders must have none of the specified tags, "any" so colliders can have any of the specified tags or "all" so colliders must have all of the specified tags. Defaults to "all".
-- @treturn[1] bool collided will be true if the collider collided with anything
-- @treturn[1] {collider, ...} a table containing all colliders
-- @treturn[2] bool collided will be false if the collider didn't collide with anything
-- @treturn[2] nil
function Map:checkCollider(collider, tag, requirement)
    local x, y, z = collider:getWorldCoords()
    local w, h, d = collider.width, collider.height, collider.depth

    local tags = tag
    if tag and type(tag) ~= "table" then tags = {tag} end
    requirement = requirement or "all"

    local filter = function(item)
        if item == collider then
            return false
        end
        if tags == nil then
            return true
        end
        return _local.doesEntityMatchTags(item, tags, requirement)
    end
    
    local items, len = self.bumpWorld:queryCube(x, y, z, w, h, d, filter)
    
    if not items or #items == 0 then return false else return true, items end
end

--- Checks for any colliders that intersect a cube formed by the passed arguments
-- @param x Position in the world
-- @param y Position in the world
-- @param z Position in the world
-- @param w The cubes width
-- @param h The cubes height
-- @param d The cubes depth
-- @param[opt] tag An optional tag to check for
-- @param[optchain] requirement requirement How strict are the tags. Can be "none" so colliders must have none of the specified tags, "any" so colliders can have any of the specified tags or "all" so colliders must have all of the specified tags. Defaults to "all".
-- @treturn[1] bool collided will be true if the cube intersected anything
-- @treturn[1] {collider, ...} a table containing all colliders
-- @treturn[2] bool collided will be false if the cube didn't intersect anything
-- @treturn[2] nil
function Map:checkCube(x, y, z, w, h, d, tags, requirement)
    local tags = tag
    if tag and type(tag) ~= "table" then tags = {tag} end
    requirement = requirement or "all"

    local filter = function(item)
        if tags == nil then
            return true
        end
        return _local.doesEntityMatchTags(item, tags, requirement)
    end
    
    local items, len = self.bumpWorld:queryCube(x, y, z, w, h, d, filter)
    
    if not items or #items == 0 then return false else return true, items end
end

function Map:registerCollider(collider)
    local realX, realY, realZ = collider:getWorldCoords()
    self.bumpWorld:add(collider, realX, realY, realZ, collider.width, collider.height, collider.depth)
    if collider.onRegistered then
        collider:onRegistered(self)
    end
end

function Map:unregisterCollider(collider)
    self.bumpWorld:remove(collider)
    if collider.onUnregistered then
        collider:onUnregistered()
    end
end

function Map:moveCollider(collider, x, y, z)
    local actualX, actualY, actualZ, cols, len = self.bumpWorld:move(collider, x, y, z)
    return actualX, actualY, actualZ
end
-- \\ End Collider Functions // --


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

function _local.generateGrid(self, mapData)
    local grid = {}

    for x=1, self.width do
        grid[x] = {}
        for y=1, self.height do
            grid[x][y] = {}
            for z=1, self.depth do
                local tileIndex = mapData.tileIndexGrid[x][y][z]
                local tileName = mapData.tileIndex[tileIndex]
                if tileName then
                    local tileData = Tiles.new(tileName, self, x, y, z)
                    grid[x][y][z] = tileData
                    self:registerCollider(tileData)
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

    self:updateTileNeighbours()

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

-- Unregister tile colliders
for x=1, self.width do
    for y=1, self.height do
        for z=1, self.depth do
            local tileData = self.grid[x][y][z]
            if tileData then
                self:unregisterCollider(tileData)
            end
        end
    end
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
                self:registerCollider(tileData)
            end
            newGrid[x][y][z] = tileData
        end
    end
end

self.width = newWidth
self.height = newHeight
self.depth = newDepth
self.grid = newGrid

self:updateTileNeighbours()

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