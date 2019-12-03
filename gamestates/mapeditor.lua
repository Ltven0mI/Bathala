local Camera = require "hump.camera"
local Camera3D = require "core.camera3d"
local Signal = require "hump.signal"
local Maf = require "core.maf"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"

local MapLoader = require "core.maploader"

local SpriteRenderer = require "core.spriterenderer"

local Animations = require "core.animations"
local Entities = require "core.entities"

local Console = require "core.console"

local MapEditor = {}

local _local = {}

local _const = {}
_const.Z_NEAR = -128
_const.Z_FAR = 128
_const.CAMERA_SPEED = 128

local _debug = {}
_debug.draw_wireframe = false
_debug.draw_depth = false


-- [[ Callbacks ]] --

function MapEditor:init()
end

function MapEditor:enter()
    self.camera = Camera3D(0, 0, 0, nil, nil, _const.Z_NEAR, _const.Z_FAR, 4)

    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW / 4, halfH / 4, 4)

    self.map = MapLoader.loadFromFile("assets/maps/debug_level.lua")
    -- self.map:exportMap("testExport.lua")
    
    -- self.player = Player(0, 0, 0)
    -- self.player:setMap(self.map)

    -- local playerSpawn = self.map:findEntityOfType("player_spawn")
    -- if playerSpawn then
    --     self.player:setPos(playerSpawn.pos:unpack())
    -- end
end

function MapEditor:leave()
    self.camera = nil
    self.uiCamera = nil

    -- self.player = nil
    self.map = nil
end

function MapEditor:update(dt)
    Timer.update(dt)

    if self.map then
        self.map:update(dt)
    end
    -- self.player:update(dt)

    -- [[ Camera Movement ]] --
    local up = love.keyboard.isDown("w")
    local down = love.keyboard.isDown("s")
    local left = love.keyboard.isDown("a")
    local right = love.keyboard.isDown("d")

    local deltaX = (left and -1 or 0) + (right and 1 or 0)
    local deltaY = (up and 1 or 0) + (down and -1 or 0)
    local inputDelta = Maf.vector(deltaX, 0, deltaY):normalize()

    local cameraMovement = inputDelta * _const.CAMERA_SPEED * dt
    self.camera:move(cameraMovement:unpack())
    -- \\ End Camera Movement // --

    -- self:lockCameraToPlayer()

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
    -- self.player:draw()

    -- [[ After Drawing Everything ]] --
    self.camera:setIsAlpha(true)
    SpriteRenderer.drawTransparentSprites()

    love.graphics.setWireframe(false)

    self.camera:detach()


    if _debug.draw_depth then
        love.graphics.setColor(1, 1, 1, 1)
        self.camera:drawDepthBuffer(0, 0)
    end


    -- self.uiCamera:attach()

    -- local screenW, screenH = self.uiCamera:worldCoords(love.graphics.getDimensions())
    -- self.player:drawUI(screenW, screenH)

    -- self.uiCamera:detach()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(love.timer.getFPS())

    Console.draw()
end

function MapEditor:mousepressed(x, y, btn)
end

function MapEditor:keypressed(key, isRepeat)
    if key == "space" then
        _debug.draw_depth = not _debug.draw_depth
    elseif key == "f1" then
        _debug.draw_wireframe = not _debug.draw_wireframe
    end
    Console.keypressed(key, isRepeat)
end

function MapEditor:textinput(text)
    Console.textinput(text)
end


-- [[ Util Functions ]] --

function MapEditor:lockCameraToPlayer()

    local screenW, screenH = love.graphics.getDimensions()
    local viewPortW = math.floor(screenW / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)
    local mapW, mapD = self.map.width * self.map.tileSize, self.map.depth * self.map.tileSize
    local halfPlayerW, halfPlayerH = math.floor(self.player.w / 2), math.floor(self.player.h / 2)

    local playerX, playerY, playerZ = self.player.pos:unpack()

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX))
    local lockZ = math.max(halfViewH, math.min(mapD - halfViewH, playerZ - halfPlayerH))

    self.camera:lockPosition(lockX, 0, lockZ)
end

return MapEditor