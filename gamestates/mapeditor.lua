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
    self.map = map
end

function MapEditor:updateSearchResults(pattern)
    self.ui.tileSelectionResultGrid:setEntries(Tiles.getTilesMatchingPattern(pattern))
end
-- \\ End Util Functions // --


-- [[ Callbacks ]] --

function MapEditor:init()
    Console.expose("editor_loadmap", function(filePath) return self:loadMap(filePath) end)
end

function MapEditor:enter()
    self.camera = Camera3D(0, 0, 0, nil, nil, _const.Z_NEAR, _const.Z_FAR, 4)

    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW, halfH, 1)

    self.map = MapLoader.loadFromFile("assets/maps/debug_level.lua")
    self.mapGrid = Grid(self.map.width, self.map.depth, self.map.tileSize)

    -- [[ UI ]] --
    self.ui = MapEditorUI(self)
    self.ui.onMousePressed = function(ui, x, y, btn)
        if self.map then
            local worldX, worldY, worldZ = self.camera:worldCoords(x, y)
            local gridX, gridY, gridZ = self.map:worldToGridPos(worldX, worldY, worldZ)
            gridY = self.selectedGridY
            if btn == 1 then
                local selectedTile = self.ui.tileSelectionResultGrid.selectedEntry
                if selectedTile then
                    self.map:setTileAt(selectedTile(self.map, gridX, gridY, gridZ), gridX, gridY, gridZ)
                end
            elseif btn == 2 then
                self.map:setTileAt(nil, gridX, gridY, gridZ)
            end
        end
    end
    self.ui.tileSelectionSearchBar.onValueChanged = function(searchBar, value)
        self:updateSearchResults(value)
    end
    self.ui.tileSelectionResultGrid.onSelectedEntryChanged = function(resultGrid, selectedTile)
        if selectedTile then
            self.selectedTileSprite = SpriteLoader.loadFromOBJ(selectedTile.spriteMeshFile, selectedTile.spriteImgFile, true)
        end
    end
    self.searchResults = {}
    self:updateSearchResults("")

    self.selectedTile = nil
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
    self.searchResults = nil
    self.selectedTile = nil
    self.selectedTileSprite = nil
    self.tileShadowSprite = nil

    self.selectedGridY = nil
end

function MapEditor:update(dt)
    Timer.update(dt)

    if self.map then
        self.map:update(dt)

        if not Console.getIsEnabled() and not self.ui.tileSelectionSearchBar.isSelected then
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

    if not Console.getIsEnabled() and not self.ui.tileSelectionSearchBar.isSelected then
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

return MapEditor