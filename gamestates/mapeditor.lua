local Camera = require "hump.camera"
local Camera3D = require "core.camera3d"
local Signal = require "hump.signal"
local Maf = require "core.maf"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"
local UTF8 = require "utf8"

local MapLoader = require "core.maploader"
local SpriteRenderer = require "core.spriterenderer"

local Tiles = require "core.tiles"
local Animations = require "core.animations"
local Entities = require "core.entities"

local Lewd = require "core.lewd"

local Console = require "core.console"

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
    self.searchResults = Tiles.getTilesMatchingPattern(pattern)
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

    -- [[ UI ]] --
    self.ui = MapEditorUI(self)
    self.ui.tileSelectionSearchBar.onValueChanged = function(searchBar, value)
        self:updateSearchResults(value)
    end
    self.searchResults = {}
    self:updateSearchResults("")

    self.selectedTile = nil
end

function MapEditor:leave()
    self.camera = nil
    self.uiCamera = nil

    self.map = nil

    self.ui = nil
    self.searchResults = nil
    self.selectedTile = nil
end

function MapEditor:update(dt)
    Timer.update(dt)

    if self.map then
        self.map:update(dt)

        if not Console.getIsEnabled() then
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
    self:drawSearchResults(self.uiCamera:worldCoords(love.graphics.getDimensions()))
    
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

    if key == "space" then
        _debug.draw_depth = not _debug.draw_depth
    elseif key == "f1" then
        _debug.draw_wireframe = not _debug.draw_wireframe
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


-- [[ Drawing Functions ]] --

function _local.drawBorder(x, y, w, h)
    love.graphics.rectangle("fill", x, y, w, 1) -- Top
    love.graphics.rectangle("fill", x, y+h-1, w, 1) -- Bottom
    love.graphics.rectangle("fill", x, y, 1, h) -- Left
    love.graphics.rectangle("fill", x+w-1, y, 1, h) -- Right
end

function MapEditor:drawSearchResults(screenW, screenH)
    if not self.map then return end

    local paddingLeft = _const.UI_HALFUNIT
    local paddingRight = _const.UI_HALFUNIT
    local totalWidth = _const.UI_RESULT_COLUMNS * _const.UI_UNIT * 2 + _const.UI_HALFUNIT * (_const.UI_RESULT_COLUMNS-1) + paddingLeft + paddingRight

    local paddingTop = _const.UI_HALFUNIT
    local paddingBottom = _const.UI_UNIT
    local totalHeight = _const.UI_RESULT_ROWS * _const.UI_UNIT * 4 + _const.UI_UNIT * (_const.UI_RESULT_ROWS-1) + paddingTop + paddingBottom

    local layoutX = screenW - totalWidth - 3
    local layoutY = screenH - totalHeight - 3 - _const.UI_UNIT - 1

    -- [[ Draw Border ]] --
    love.graphics.setColor(1, 1, 1, 1)
    _local.drawBorder(layoutX-1, layoutY-1, totalWidth+2, totalHeight+2)

    -- [[ Draw Results ]] --
    for i, entry in ipairs(self.searchResults) do
        local row = math.floor((i-1) / _const.UI_RESULT_COLUMNS)
        local column = (i-1) % _const.UI_RESULT_COLUMNS

        if row >= _const.UI_RESULT_ROWS then
            break
        end

        local x = layoutX + paddingLeft + column * (_const.UI_UNIT * 2 + _const.UI_HALFUNIT)
        local y = layoutY + paddingTop + row * (_const.UI_UNIT * 5)

        -- [[ Set color based on whether the tile is selected or not ]] --
        if entry == self.selectedTile then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        
        _local.drawBorder(x-1, y-1, _const.UI_UNIT * 2 + 2, _const.UI_UNIT * 4 + 2)
    end
end
-- \\ End Drawing Functions // --

return MapEditor