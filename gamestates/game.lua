local Camera = require "hump.camera"
local Camera3D = require "core.camera3d"
local Signal = require "hump.signal"
local Maf = require "core.maf"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"

local SpriteRenderer = require "core.spriterenderer"

local MapLoader = require "core.maploader"
local Animations = require "core.animations"
local Entities = require "core.entities"

local Console = require "core.console"

local game = {}

local _local = {}
_local.timeBetweenEnemySpawns = 0.75
_local.timeBetweenWaves = 5
_local.timeBeforeRestart = 3

local _const = {}
_const.Z_NEAR = -128
_const.Z_FAR = 128

local _debug = {}
_debug.draw_wireframe = false
_debug.draw_depth = false


-- [[ Callbacks ]] --

function game:init()
    Console.expose("spawn", function(...) return _local.console_spawn(self, ...) end)
end

function game:enter()
    self.camera = Camera3D(0, 0, 0, nil, nil, _const.Z_NEAR, _const.Z_FAR, 4)

    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW / 4, halfH / 4, 4)

    self.map = MapLoader.loadFromFile("assets/maps/level1.lua")
    
    self.player = Entities.new("player", 0, 0, 0)
    self.map:registerEntity(self.player)

    local playerSpawn = self.map:findEntityWithTag("player_spawn")
    if playerSpawn then
        self.player:setPos(playerSpawn.pos:unpack())
    end

    self:registerSignalCallbacks()

    self.currentWave = {
        num = 0,
        spawnedEnemyCount = 0,
        totalEnemies = 0
    }

    self.luckydrops = {
        Entities.get("curse_powerup"),
        Entities.get("sinigang_powerup"),
        Entities.get("barricade_item"),
        Entities.get("barricade_item")
    }

    self:nextWave()
end

function game:leave()
    self.camera = nil
    self.uiCamera = nil

    self.player = nil
    self.map = nil

    self:clearSignalCallbacks()

    self.currentWave = nil
    self.enemyCount = nil

    self.luckydrops = nil
end

function game:update(dt)
    Timer.update(dt)

    self.map:update(dt)

    self:lockCameraToPlayer()

    Console.update(dt)
end

function game:draw()
    self.camera:attach()
    self.camera:setIsAlpha(false)

    if _debug.draw_wireframe then
        love.graphics.setWireframe(true)
    end

    self.map:draw()

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

    local screenW, screenH = self.uiCamera:worldCoords(love.graphics.getDimensions())
    self.player:drawUI(screenW, screenH)

    self.uiCamera:detach()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(love.timer.getFPS())

    -- local screenW, screenH = love.graphics.getDimensions()
    -- love.graphics.line(0, math.floor(screenH / 2), screenW, math.floor(screenH / 2))
    -- love.graphics.line(math.floor(screenW / 2), 0, math.floor(screenW / 2), screenH)

    Console.draw()
end

function game:mousepressed(x, y, btn)
    local worldX, worldY, worldZ = self.camera:worldCoords(x, y)
    local dir = (Maf.vector(worldX, worldY, worldZ) - self.player.pos):normalize()
    self.player:mousepressed(btn, dir)
end

function game:keypressed(key, isRepeat)
    if key == "space" then
        _debug.draw_depth = not _debug.draw_depth
    elseif key == "f1" then
        _debug.draw_wireframe = not _debug.draw_wireframe
    elseif key == "f2" then
        print("CAPTURED SCREENSHOT")
        love.graphics.captureScreenshot(string.format("screenshot_%s.png", os.date("%Y%m%d_%H%M%S")))
    end
    Console.keypressed(key, isRepeat)
end

function game:textinput(text)
    Console.textinput(text)
end


-- [[ Util Functions ]] --

function game:lockCameraToPlayer()

    local screenW, screenH = love.graphics.getDimensions()
    local viewPortW = math.floor(screenW / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)
    local mapW, mapD = self.map.width * self.map.tileSize, self.map.depth * self.map.tileSize
    local halfPlayerW, halfPlayerH = math.floor(self.player.width / 2), math.floor(self.player.height / 2)

    local playerX, playerY, playerZ = self.player.pos:unpack()

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX))
    local lockZ = math.max(halfViewH, math.min(mapD - halfViewH, playerZ - halfPlayerH))

    self.camera:lockPosition(lockX, 0, lockZ)
end

function game:spawnEnemy(spawner)
    local enemyInstance = Entities.new("enemy", spawner.pos.x, spawner.pos.y, spawner.pos.z)
    self.map:registerEntity(enemyInstance)
    enemyInstance:start()
    self.currentWave.spawnedEnemyCount = self.currentWave.spawnedEnemyCount + 1
end

function game:spawnEnemies(count)
    -- local spawners = self.map:getAllEntitiesWithTag("spawner")
    -- if spawners == nil then
    --     error("Failed to spawn enemies: No spawners found!")
    -- end

    -- self.currentWave.totalEnemies = count

    -- Timer.every(_local.timeBetweenEnemySpawns, function()
    --     self:spawnEnemy(spawners[love.math.random(1, #spawners)])
    -- end, count)
end

function game:spawnEntitiesRandomly(entityType, count)
    -- TODO: Need to reimplement this
    -- -- No point continuing if count is less than 1 lmao
    -- if count < 1 then return end

    -- for i=1, count do
    --     while true do
    --         local randX = love.math.random(1, self.map.width)
    --         local randY = love.math.random(1, self.map.height)

    --         local tileData = self.map:getTileAt(randX, randY, Map.LAYER_COLLISION)
    --         if tileData == nil or tileData.isSolid == false then
    --             local worldX, worldY = self.map:gridToWorldPos(randX, randY)
    --             local halfTileSize = math.floor(self.map.tileSize / 2)

    --             local instance = Entities.new(entityType, worldX + halfTileSize, worldY + halfTileSize)
    --             self.map:registerEntity(instance)

    --             -- Succesfully spawned a new element so break out of while loop
    --             break
    --         end
    --     end
    -- end
end

-- [[ Game State Functions ]] --

function game:nextWave()
    self.currentWave.num = self.currentWave.num + 1
    self.currentWave.spawnedEnemyCount = 0
    self.totalEnemies = 0
    self:spawnEnemies(self.currentWave.num)
    self:spawnEntitiesRandomly("vase", love.math.random(-1, 3))
    self:spawnEntitiesRandomly("boulder", love.math.random(-1, 3))
end

function game:gameover()
    Signal.emit("gameover")
    Timer.after(_local.timeBeforeRestart, function() self:restart() end)
end

function game:restart()
    Timer.clear()
    Gamestate.switch(game)
end


-- [[ Signal Callbacks ]] --

function game:registerSignalCallbacks()
    Signal.register("vase-smashed", function(...) self.vase_smashed(self, ...) end)
    Signal.register("statue-heal", function(...) self.statue_heal(self, ...) end)
    Signal.register("enemy-died", function(...) self.enemy_died(self, ...) end)
    Signal.register("statue-died", function(...) self.statue_died(self, ...) end)
    Signal.register("player-died", function(...) self.statue_died(self, ...) end)
end

function game:clearSignalCallbacks()
    Signal.clear("vase-smashed")
    Signal.clear("statue-heal")
    Signal.clear("enemy-died")
    Signal.clear("statue-died")
    Signal.clear("player-died")
    Signal.clear("gameover")
end

function game:vase_smashed(x, y, z)
    local rand = 1 --love.math.random(1, 2)
    if rand == 1 then
        local drop = self.luckydrops[love.math.random(1, #self.luckydrops)]
        local dropInstance = drop(x, y, z)
        self.map:registerEntity(dropInstance)
    end
end

function game:enemy_died(enemy)
    -- self.enemyCount = self.enemyCount - 1
    local foundEnemies = self.map:getAllEntitiesWithTag("enemy")

    print("EnemyDied! Enemies left: "..(foundEnemies and #foundEnemies or 0))
    print(self.currentWave.spawnedEnemyCount, self.currentWave.totalEnemies)
    if self.currentWave.spawnedEnemyCount == self.currentWave.totalEnemies and foundEnemies == nil then
        Timer.after(_local.timeBetweenWaves, function() self:nextWave() end)
    end
end

function game:statue_heal(amount)
    local statue = self.map:findEntityOfType("statue")
    if statue then
        statue:heal(amount)
    end
end

function game:statue_died(statue)
    self:gameover()
end


-- [[ Console Functions ]] --

function _local.console_spawn(self, entityName, xStr, yStr, zStr)
    local entity, err = Entities.get(entityName)
    if not entity then
        return false, string.format("Failed to spawn entity '%s' : %s", entityName, err)
    end
    local argStrings = {xStr, yStr, zStr}
    local argNums = {}
    for i, str in ipairs(argStrings) do
        local num = tonumber(str)
        if not num then
            return false, string.format("Invalid argument #%d expected number received '%s'", i, str)
        end
        table.insert(argNums, num)
    end
    print(argNums[1], argNums[2], argNums[3])
    self.map:registerEntity(entity(argNums[1], argNums[2], argNums[3]))
    return true
end
-- \\ End Console Functions // --


return game