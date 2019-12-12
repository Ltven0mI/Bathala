local Camera = require "hump.camera"
local Camera3D = require "core.camera3d"
local Signal = require "hump.signal"
local Maf = require "core.maf"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"
local UTF8 = require "utf8"

local MapLoader = require "core.maploader"
local SpriteRenderer = require "core.spriterenderer"
local SpriteLoader = require "core.spriteloader"

local Console = require "core.console"
local Tiles = require "core.tiles"
local Animations = require "core.animations"
local Entities = require "core.entities"

local Grid = require "classes.grid"


local Lewd = require "core.lewd"
local MapEditorUI = require "ui.ui_mapeditor"

local MapEditor = {}

local _const = {}
_const.Z_NEAR = -128
_const.Z_FAR = 128
_const.CAMERA_SPEED = 128

_const.UI_UNIT = 16
_const.UI_HALFUNIT = 8
_const.UI_RESULT_COLUMNS = 6
_const.UI_RESULT_ROWS = 2

local _local = {}

local _debug = {}
_debug.draw_wireframe = false
_debug.draw_depth = false


-- [[ Util Functions ]] --

function MapEditor:loadMap(filePath)
    local map, err = MapLoader.loadFromFile(filePath)
    if not map then
        return false, err
    end
    self:setMap(map)
    return true
end

function MapEditor:newMap(width, height, depth)
    self:setMap(MapLoader.newEmptyMap(width, height, depth))
    return true
end

function MapEditor:exportMap(filePath)
    if not self.map then
        return false, "Failed to export map : No map loaded."
    end
    local success, err = self.map:exportMap(filePath)
    if not success then
        return false, string.format("Failed to export map to file '%s' : %s", filePath, err)
    end
    return true
end

function MapEditor:expandMap(left, right, up, down, forward, backward)
    if not self.map then
        return false, "Failed to expand map : No loaded Map."
    end
    local success, err = self.map:expand(left, right, up, down, forward, backward)
    if not success then
        return false, err
    end
    self:setMap(self.map)
    return true
end

function MapEditor:contractMap(left, right, up, down, forward, backward)
    if not self.map then
        return false, "Failed to contract map : No loaded Map."
    end
    local success, err = self.map:contract(left, right, up, down, forward, backward)
    if not success then
        return false, err
    end
    self:setMap(self.map)
    return true
end

function MapEditor:setMap(map)
    self.map = map
    self.mapGrid = Grid(self.map.width, self.map.depth, self.map.tileSize)
end

function MapEditor:updateSearchResults(pattern)
    self.ui.tileSelectionResultGrid:setEntries(Tiles.getTilesMatchingPattern(pattern))
    self.ui.entitySelectionResultGrid:setEntries(Entities.getEntitiesMatchingPattern(pattern))
end
-- \\ End Util Functions // --


-- [[ Callbacks ]] --

function MapEditor:init()
    Console.expose("editor_loadmap", function(...) return _local.console_loadmap(self, ...) end)
    Console.expose("editor_newmap", function(...) return _local.console_newmap(self, ...) end)
    Console.expose("editor_exportmap", function(...) return _local.console_exportmap(self, ...) end)
    Console.expose("editor_expandmap", function(...) return _local.console_expandmap(self, ...) end)
    Console.expose("editor_contractmap", function(...) return _local.console_contractmap(self, ...) end)
end

function MapEditor:enter()
    self.camera = Camera3D(0, 0, 0, nil, nil, _const.Z_NEAR, _const.Z_FAR, 4)

    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW, halfH, 1)

    self:newMap(3, 3, 3)

    -- [[ UI ]] --
    self.ui = MapEditorUI(self)
    self.ui.onMousePressed = function(ui, x, y, btn)
        if self.map then
            local worldX, worldY, worldZ = self.camera:worldCoords(x, y)
            local gridX, gridY, gridZ = self.map:worldToGridPos(worldX, worldY, worldZ)
            gridY = self.selectedGridY
            if btn == 1 then
                if self.selectedTile then
                    self.map:setTileAt(self.selectedTile(self.map, gridX, gridY, gridZ), gridX, gridY, gridZ)
                elseif self.selectedEntity then
                    self.map:registerEntity(self.selectedEntity(worldX, worldY, worldZ))
                end
            elseif btn == 2 then
                self.map:setTileAt(nil, gridX, gridY, gridZ)
            end
        end
    end
    self.ui.onMouseMoved = function(ui, x, y, dx, dy)
        if self.map then
            local worldX, worldY, worldZ = self.camera:worldCoords(x, y)
            local gridX, gridY, gridZ = self.map:worldToGridPos(worldX, worldY, worldZ)
            gridY = self.selectedGridY
            if love.mouse.isDown(1) then
                local selectedTile = self.ui.tileSelectionResultGrid.selectedEntry
                if selectedTile then
                    self.map:setTileAt(selectedTile(self.map, gridX, gridY, gridZ), gridX, gridY, gridZ)
                end
            elseif love.mouse.isDown(2) then
                self.map:setTileAt(nil, gridX, gridY, gridZ)
            end
        end
    end
    self.ui.selectionSearchBar.onValueChanged = function(searchBar, value)
        self:updateSearchResults(value)
    end
    self.ui.tileSelectionResultGrid.onSelectedEntryChanged = function(resultGrid, selectedTile)
        if selectedTile then
            self.selectedTileSprite = SpriteLoader.loadFromOBJ(selectedTile.spriteMeshFile, selectedTile.spriteImgFile, true)
            self.ui.entitySelectionResultGrid:setSelectedEntry(nil)
        end
        self.selectedTile = selectedTile
    end
    self.ui.entitySelectionResultGrid.onSelectedEntryChanged = function(resultGrid, selectedEntity)
        if selectedEntity then
            -- self.selectedTileSprite = SpriteLoader.loadFromOBJ(selectedTile.spriteMeshFile, selectedTile.spriteImgFile, true)
            self.selectedTileSprite = nil
            self.ui.tileSelectionResultGrid:setSelectedEntry(nil)
        end
        self.selectedEntity = selectedEntity
    end
    self:updateSearchResults("")

    self.selectedTile = nil
    self.selectedEntity = nil
    self.selectedTileSprite = nil
    self.tileShadowSprite = SpriteLoader.loadFromOBJ("assets/meshes/tile_shadow.obj", nil, true)

    self.selectedGridY = 1
end

function MapEditor:leave()
    self.camera = nil
    self.uiCamera = nil

    self.map = nil
    self.mapGrid = nil

    self.ui = nil
    self.selectedTile = nil
    self.selectedEntity = nil
    self.selectedTileSprite = nil
    self.tileShadowSprite = nil

    self.selectedGridY = nil
end

function MapEditor:update(dt)
    Timer.update(dt)

    if self.map then
        self.map:update(dt)

        if not Console.getIsEnabled() and not self.ui.selectionSearchBar.isSelected then
            self:updateCameraMovement(dt)
        end
    end

    Console.update(dt)
end

function MapEditor:draw()
    self.camera:attach()
    self.camera:setIsAlpha(false)

    if _debug.draw_wireframe then
        love.graphics.setWireframe(true)
    end

    if self.map then
        self.map:draw()
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        self.mapGrid:draw(0, -1, 1)

        if self.selectedTileSprite then
            local mx, my = love.mouse.getPosition()
            local worldX, worldY, worldZ = self.camera:worldCoords(mx, my)
            local gridX, gridY, gridZ = self.map:worldToGridPos(worldX, worldY, worldZ)
            worldX, worldY, worldZ = self.map:gridToWorldPos(gridX, self.selectedGridY, gridZ)
            love.graphics.setColor(1, 1, 1, 0.5)
            self.selectedTileSprite:draw(worldX, worldY, worldZ)
            worldX, worldY, worldZ = self.map:gridToWorldPos(gridX, gridY, gridZ)
            love.graphics.setColor(0, 0, 0, 0.5)
            self.tileShadowSprite:draw(worldX, worldY, worldZ)
        end
    end

    -- [[ After Drawing Everything ]] --
    self.camera:setIsAlpha(true)
    SpriteRenderer.drawTransparentSprites()

    love.graphics.setWireframe(false)

    self.camera:detach()


    if _debug.draw_depth then
        love.graphics.setColor(1, 1, 1, 1)
        self.camera:drawDepthBuffer(0, 0)
    end


    self.uiCamera:attach()
    
    Lewd.core.clearZones()
    self.ui:draw(self.ui:getRealPos())
    
    -- Lewd.core.drawZoneMap(0, 0)

    self.uiCamera:detach()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(love.timer.getFPS())

    Console.draw()
end

function MapEditor:mousepressed(x, y, btn, isTouch)
    Lewd.mousepressed(x, y, btn, isTouch)
end

function MapEditor:mousemoved(x, y, dx, dy, isTouch)
    Lewd.mousemoved(x, y, dx, dy, isTouch)
end

function MapEditor:mousereleased(x, y, btn, isTouch)
    Lewd.mousereleased(x, y, btn, isTouch)
end

function MapEditor:keypressed(key, scancode, isRepeat)
    Lewd.keypressed(key, scancode, isRepeat)

    if not Console.getIsEnabled() and not self.ui.selectionSearchBar.isSelected then
        if key == "up" then
            self.selectedGridY = self.selectedGridY + 1
        elseif key == "down" then
            self.selectedGridY = self.selectedGridY - 1
        end
        self.selectedGridY = math.max(1, math.min(self.map.height, self.selectedGridY))

        if key == "space" then
            _debug.draw_depth = not _debug.draw_depth
        elseif key == "f1" then
            _debug.draw_wireframe = not _debug.draw_wireframe
        end
    end
    Console.keypressed(key, isRepeat)
end

function MapEditor:textinput(text)
    Lewd.textinput(text)
    Console.textinput(text)
end
-- \\ End Callback Functions // --


-- [[ Update Functions ]] --

function MapEditor:updateCameraMovement(dt)
    local up = love.keyboard.isDown("w")
    local down = love.keyboard.isDown("s")
    local left = love.keyboard.isDown("a")
    local right = love.keyboard.isDown("d")

    local deltaX = (left and -1 or 0) + (right and 1 or 0)
    local deltaY = (up and 1 or 0) + (down and -1 or 0)
    local inputDelta = Maf.vector(deltaX, 0, deltaY):normalize()

    local cameraMovement = inputDelta * _const.CAMERA_SPEED * dt
    self.camera:move(cameraMovement:unpack())
end
-- \\ End Update Functions // --


-- [[ Console Functions ]] --

function _local.console_loadmap(self, filePath)
    return self:loadMap(filePath)
end

function _local.console_newmap(self, widthStr, heightStr, depthStr)
    local widthNum = tonumber(widthStr)
    if widthNum == nil then
        return false, string.format("Invalid argument #1 expected number received '%s'", widthStr)
    end
    local heightNum = tonumber(heightStr)
    if heightNum == nil then
        return false, string.format("Invalid argument #2 expected number received '%s'", heightStr)
    end
    local depthNum = tonumber(depthStr)
    if depthNum == nil then
        return false, string.format("Invalid argument #3 expected number received '%s'", depthStr)
    end
    return self:newMap(widthNum, heightNum, depthNum)
end

function _local.console_exportmap(self, filePath)
    return self:exportMap(filePath)
end

function _local.console_expandmap(self, leftStr, rightStr, upStr, downStr, forwardStr, backwardStr)
    local argStrings = {leftStr, rightStr, upStr, downStr, forwardStr, backwardStr}
    local argNums = {}
    for i, str in ipairs(argStrings) do
        local num = tonumber(str)
        if not num then
            return false, string.format("Invalid argument #%d expected number received '%s'", i, str)
        end
        table.insert(argNums, num)
    end
    return self:expandMap(unpack(argNums))
end

function _local.console_contractmap(self, leftStr, rightStr, upStr, downStr, forwardStr, backwardStr)
    local argStrings = {leftStr, rightStr, upStr, downStr, forwardStr, backwardStr}
    local argNums = {}
    for i, str in ipairs(argStrings) do
        local num = tonumber(str)
        if not num then
            return false, string.format("Invalid argument #%d expected number received '%s'", i, str)
        end
        table.insert(argNums, num)
    end
    return self:contractMap(unpack(argNums))
end
-- \\ End Console Functions // --

return MapEditor