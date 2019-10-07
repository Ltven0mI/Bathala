local Camera = require "hump.camera"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"
local Map = require "classes.map"

local utf8 = require "utf8"

local editor = {}

editor.camera = nil
editor.player = nil
editor.tileset = nil
editor.map = nil

editor.isSearchSelected = false
editor.currentSearch = ""
editor.currentTileEntry = nil
editor.matchingTiles = {}
editor.currentLayerId = 1

local assets = AssetBundle("assets", {
    "player/player_temp.png",
    "maps/level1.lua",
    "tilesets/default_tileset.lua"
})

function editor:init()
    love.keyboard.setKeyRepeat(true)
end

function editor:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.tileset = assets.tilesets.default_tileset
    self.tileset.load()

    self.map = Map(assets.maps.level1, self.tileset)
    self.map:generateGrid()
    
    self.player = Player(assets.player.player_temp)
    self.player:setMap(self.map)

    self:updateSearchResults()
end

function editor:leave()
    AssetBundle.unload(assets)

    self.camera = nil
    self.player = nil

    self.tileset.unload()
    self.tileset = nil

    self.map = nil
end

function editor:update(dt)
    self.player:update(dt)

    local playerX, playerY = self.player.pos:unpack()

    local screenW, screenH = love.graphics.getDimensions()

    local viewPortW = math.floor((screenW - 200) / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)

    local mapW, mapH = self.map.width * self.map.tileSize, self.map.height * self.map.tileSize

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX)) - math.floor(100 / self.camera.scale)
    local lockY = math.max(halfViewH, math.min(mapH - halfViewH, playerY))

    self.camera:lockPosition(lockX, lockY)
end

function editor:drawLayerSeperator()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, self.map.width * self.map.tileSize, self.map.height * self.map.tileSize)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    for x=1, self.map.width do
        local lineX = (x-1) * self.map.tileSize
        love.graphics.rectangle("fill", lineX, 0, 1, self.map.height * self.map.tileSize)
    end
    for y=1, self.map.height do
        local lineY = (y-1) * self.map.tileSize
        love.graphics.rectangle("fill", 0, lineY, self.map.width * self.map.tileSize, 1)
    end
end

function editor:draw()
    self.camera:attach()

    if self.currentLayerId == 1 then
        self:drawLayerSeperator()
    end
    self.map:draw(1, 1)
    self.player:draw()
    if self.currentLayerId == 2 then
        self:drawLayerSeperator()
    end
    self.map:draw(2, math.max(2, math.min(self.currentLayerId-1, self.map.layerCount)))
    if self.currentLayerId > 2 then
        self:drawLayerSeperator()
    end
    if self.currentLayerId <= self.map.layerCount then
        self.map:draw(math.max(3, self.currentLayerId))
    end

    self.camera:detach()

    local screenW, screenH = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 200, screenH)
    if self.isSearchSelected then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle("line", 2, 2, 196, 20)
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.currentSearch, 4, 4)
    love.graphics.print("Layer: "..self.currentLayerId, 0, 20)

    local x = 0
    local y = 0
    for i, entry in ipairs(self.matchingTiles) do
        if self.currentTileEntry and entry.key == self.currentTileEntry.key then
            love.graphics.setColor(0, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.rectangle("line", 10 + (x * (64 + 4)) - 1, 50 + (y * (64 + 4)) - 1, 64 + 2, 64 + 2)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(entry.tileData.img, 10 + (x * (64 + 4)), 50 + (y * (64 + 4)), 0, 4, 4)
        x = x + 1
        if x >= 2 then
            y = y + 1
            x = 0
        end
    end
end

function editor:mousepressed(x, y, btn)
    if x > 200 then
        local worldX, worldY = self.camera:worldCoords(x, y)
        local gridX, gridY = self.map:worldToGridPos(worldX, worldY, self.currentLayerId)

        if btn == 1 and self.currentTileEntry ~= nil then
            self.map:setTileAt(self.currentTileEntry.tileData, gridX, gridY, self.currentLayerId)
        elseif btn == 2 then
            self.map:setTileAt(nil, gridX, gridY, self.currentLayerId)
        end
    else
        self.isSearchSelected = true
        local xOffset = 0
        local yOffset = 0
        for i, entry in ipairs(self.matchingTiles) do
            local drawX, drawY = 10 + (xOffset * (64 + 4)), 50 + (yOffset * (64 + 4))

            if x >= drawX and x < drawX + 64 and y >= drawY and y < drawY + 64 then
                self.currentTileEntry = entry
                self.isSearchSelected = false
                break
            end

            xOffset = xOffset + 1
            if xOffset >= 2 then
                yOffset = yOffset + 1
                xOffset = 0
            end
        end
    end
end

function editor:updateSearchResults()
    self.matchingTiles = {}
    for k, v in pairs(self.tileset.tiles) do
        if string.find(k, self.currentSearch) then
            table.insert(self.matchingTiles, {key=k, tileData=v})
        end
    end
end

function editor:textinput(text)
    if self.isSearchSelected then
        self.currentSearch = self.currentSearch .. text
        self:updateSearchResults()
    end
end

function editor:keypressed(key)
    if key == "backspace" and self.isSearchSelected then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.currentSearch, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self.currentSearch = string.sub(self.currentSearch, 1, byteoffset - 1)
        end
        self:updateSearchResults()
    elseif key == "up" then
        self.currentLayerId = self.currentLayerId + 1
    elseif key == "down" then
        self.currentLayerId = self.currentLayerId - 1
    end

    if key == "s" and not self.isSearchSelected and love.keyboard.isDown("lctrl") then
        self:exportMap(self.map)
    end
end

local function _tableToString(t)
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
            valString = _tableToString(v)
        else
            error(string.format("TableToString only supports values of types 'string', 'number' and 'table'... Not '%s'", vType))
        end

        result = result .. string.format("[%s]=%s,\n", keyString, valString)
    end

    return result .. "}"
end

function editor:exportMap(map)
    local headerPattern = [[local m = {}
m.width = %d
m.height = %d]]
    local headerString = string.format(headerPattern, map.width, map.height)

    local tilesUsed = {}
    for layerId=1, map.layerCount do
        for x=1, map.width do
            for y=1, map.height do
                local tileData = map.grids[layerId][x][y]
                if tileData ~= nil then
                    if tilesUsed[tileData.name] == nil then
                        tilesUsed[tileData.name] = tileData
                    end
                end
            end
        end
    end

    local tileIndex = {}
    local reverseTileIndex = {}
    for name, tileData in pairs(tilesUsed) do
        table.insert(tileIndex, name)
        reverseTileIndex[name] = #tileIndex
    end

    local tileIndexPattern = "m.tileIndex = %s"
    local tileIndexString = string.format(tileIndexPattern, _tableToString(tileIndex))

    local decimalLayouts = {}

    for layerId=1, map.layerCount do
        decimalLayouts[layerId] = {}
        for x=1, map.width do
            decimalLayouts[layerId][x] = {}
            for y=1, map.height do
                local tileData = map.grids[layerId][x][y]
                if tileData == nil then
                    decimalLayouts[layerId][x][y] = 0
                else
                    decimalLayouts[layerId][x][y] = reverseTileIndex[tileData.name]
                end
            end
        end
    end

    local layoutsPattern = "m.layouts=%s"
    local layoutsString = string.format(layoutsPattern, _tableToString(decimalLayouts))
    
    local footerString = "return m"

    local filePattern = "%s\n%s\n%s\n%s"
    local fileString = string.format(filePattern, headerString,
    tileIndexString, layoutsString, footerString)

    print(fileString)

    love.filesystem.write("mapExport.lua", fileString)
end

return editor