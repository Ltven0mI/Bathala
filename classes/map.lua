local Class = require "hump.class"
local AssetBundle = require "AssetBundle"

local Map = Class{
    init = function(self, mapData, tileset)
        self.width = mapData.width
        self.height = mapData.height
        self.layouts = mapData.layouts
        self.layerCount = #self.layouts
        self.mapData = mapData
        self.tileset = tileset
        self.entities = {}
        self.hasStarted = false
    end,
    tileSize=16
}

-- TODO: Change entity management to use a non shifting table
-- and keep track of the index it's inserted at
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
            if entity:intersectPoint(x, y) then
                return entity
            end
        end
    end
    return nil
end

function Map:worldToGridPos(x, y, layerId)
    local layerId = layerId or 1
    return math.floor(x / self.tileSize) + 1, math.floor(y / self.tileSize) + math.max(1, layerId-1)
end

function Map:gridToWorldPos(x, y, layerId)
    local layerId = layerId or 1
    return (x-1) * self.tileSize, (y-math.max(1, layerId-1)) * self.tileSize
end

function Map:getTileAt(x, y, layerId)
    local layerId = layerId or 1
    if x < 1 or y < 1 or x > self.width or y > self.height or layerId < 1 or layerId > self.layerCount then
        return nil
    end
    return self.grids[layerId][x][y]
end

function Map:setTileAt(tileData, x, y, layerId)
    local layerId = layerId or 1
    if x < 1 or y < 1 or x > self.width or y > self.height or layerId < 1 or layerId > self.layerCount then
        return nil
    end
    self.grids[layerId][x][y] = tileData
end

function Map:generateGrid()
    self.grids = {}

    for i=1, #self.layouts do
        self.grids[i] = {}
        for x=1, self.width do
            self.grids[i][x] = {}
            for y=1, self.height do
                local id = self.layouts[i][x][y]
                local tileKey = self.mapData.tileIndex[id]
                if tileKey then
                    self.grids[i][x][y] = self.tileset.tiles[tileKey]
                end
            end
        end
    end

    for _, v in ipairs(self.mapData.entities) do
        local entityData = self.tileset.entities[v.name]
        if entityData ~= nil then
            local entityInstance = entityData.entity(v.x, v.y)
            self:registerEntity(entityInstance)
        else
            print("[WARN] Unknown entity with name '"..tostring(v.name).."'")
        end
    end
end

-- function Map:generateGridModified()
--     self.grids = {}

--     for i=1, #self.layouts do
--         self.grids[i] = {}
--         for x=1, self.width+2 do
--             self.grids[i][x] = {}
--             for y=1, self.height+2 do
--                 local id = self.layouts[i][math.min(math.max(x-1, 1), self.width)][math.min(math.max(y-1, 1), self.height)]
--                 local tileKey = self.mapData.tileIndex[id]
--                 if tileKey then
--                     self.grids[i][x][y] = self.tileset.tiles[tileKey]
--                 end
--             end
--         end
--     end
--     self.width = self.width + 2
--     self.height = self.height + 2

--     for _, v in ipairs(self.mapData.entities) do
--         local entityData = self.tileset.entities[v.name]
--         if entityData ~= nil then
--             local entityInstance = entityData.entity(v.x + self.tileSize, v.y + self.tileSize)
--             self:registerEntity(entityInstance)
--         else
--             print("[WARN] Unknown entity with name '"..tostring(v.name).."'")
--         end
--     end
-- end

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

function Map:draw(minLayer, maxLayer)
    local minLayer = minLayer or 1
    local maxLayer = maxLayer or self.layerCount

    love.graphics.setColor(1, 1, 1, 1)
    -- local offsetX = math.floor(self.width * self.tileSize / 2)
    -- local offsetY = math.floor(self.height * self.tileSize / 2)

    for i=minLayer, maxLayer do
        for x=1, self.width do
            for y=1, self.height do
                local tileData = self.grids[i][x][y]

                if tileData ~= nil then
                    local drawX, drawY = (x-1) * self.tileSize, (y-math.max(1, i-1)) * self.tileSize
                    love.graphics.draw(tileData.img, drawX, drawY)
                end
            end
        end
    end
end

function Map:drawEntities()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

return Map