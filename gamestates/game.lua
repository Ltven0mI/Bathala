local Camera = require "hump.camera"
local Signal = require "hump.signal"
local Vector = require "hump.vector"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"
local Map = require "classes.map"

local Entities = require "core.entities"

local game = {}

game.camera = nil
game.uiCamera = nil
game.player = nil
game.map = nil
game.currentWave = nil

local _local = {}
_local.timeBetweenEnemySpawns = 0.75
_local.timeBetweenWaves = 5
_local.timeBeforeRestart = 3

local assets = AssetBundle("assets", {
    maps={
        level1="mapExport.lua"
    },
})

function game:init()
    AssetBundle.load(assets)
end

function game:enter()
    -- AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW / 4, halfH / 4, 4)

    self.map = Map(assets.maps.level1)
    self.map:generateGrid()
    
    self.player = Player(0, 0)
    self.player:setMap(self.map)

    local playerSpawn = self.map:findEntityOfType("player_spawn")
    if playerSpawn then
        self.player.pos.x = playerSpawn.pos.x
        self.player.pos.y = playerSpawn.pos.y
    end

    Signal.register("vase-smashed", function(...) self.vase_smashed(self, ...) end)
    Signal.register("statue-heal", function(...) self.statue_heal(self, ...) end)
    Signal.register("enemy-died", function(...) self.enemy_died(self, ...) end)
    Signal.register("statue-died", function(...) self.statue_died(self, ...) end)
    Signal.register("player-died", function(...) self.statue_died(self, ...) end)

    self.currentWave = {
        num = 0,
        spawnedEnemyCount = 0,
        totalEnemies = 0
    }
    -- self.enemyCount = 0

    self.luckydrops = {
        Entities.get("curse_powerup"),
        Entities.get("sinigang_powerup"),
        Entities.get("barricade_item"),
        Entities.get("barricade_item")
    }

    self:nextWave()
end

function game:leave()
    -- AssetBundle.unload(assets)

    self.camera = nil
    self.uiCamera = nil
    self.player = nil

    self.map = nil

    Signal.clear("vase-smashed")
    Signal.clear("statue-heal")
    Signal.clear("enemy-died")
    Signal.clear("statue-died")
    Signal.clear("player-died")
    Signal.clear("gameover")

    self.currentWave = nil
    self.enemyCount = nil

    self.luckydrops = nil
end

function game:update(dt)
    Timer.update(dt)

    self.map:update(dt)
    self.player:update(dt)

    local playerX, playerY = self.player.pos:unpack()

    local screenW, screenH = love.graphics.getDimensions()

    local viewPortW = math.floor(screenW / self.camera.scale)
    local viewPortH = math.floor(screenH / self.camera.scale)

    local halfViewW, halfViewH = math.floor(viewPortW / 2), math.floor(viewPortH / 2)

    local mapW, mapH = self.map.width * self.map.tileSize, self.map.height * self.map.tileSize

    local halfPlayerW, halfPlayerH = math.floor(self.player.w / 2), math.floor(self.player.h / 2)

    local lockX = math.max(halfViewW, math.min(mapW - halfViewW, playerX + halfPlayerW))
    local lockY = math.max(halfViewH, math.min(mapH - halfViewH, playerY + halfPlayerH))

    self.camera:lockPosition(lockX, lockY)
end

function game:draw()
    self.camera:attach()

    self.map:draw(1, 2)
    self.map:drawEntities()
    self.player:draw()
    self.map:draw(3)

    self.camera:detach()


    self.uiCamera:attach()

    local screenW, screenH = self.uiCamera:worldCoords(love.graphics.getDimensions())
    self.player:drawUI(screenW, screenH)

    self.uiCamera:detach()

    -- local screenW, screenH = love.graphics.getDimensions()
    -- love.graphics.line(0, math.floor(screenH / 2), screenW, math.floor(screenH / 2))
    -- love.graphics.line(math.floor(screenW / 2), 0, math.floor(screenW / 2), screenH)
end

-- function game:keypressed(key)
--     if key == "f2" then
--         love.graphics.captureScreenshot("screenshot.png")
--     end
-- end

function game:mousepressed(x, y, btn)
    local worldX, worldY = self.camera:worldCoords(x, y)
    local dir = (Vector(worldX, worldY) - self.player.pos):normalized()
    self.player:mousepressed(btn, dir)
end

function game:vase_smashed(x, y)
    local rand = 1 --love.math.random(1, 2)
    if rand == 1 then
        local drop = self.luckydrops[love.math.random(1, #self.luckydrops)]
        local dropInstance = drop(x, y)
        self.map:registerEntity(dropInstance)
    end
end

function game:statue_heal(amount)
    local statue = self.map:findEntityOfType("statue")
    if statue then
        statue:heal(amount)
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

function game:statue_died(statue)
    self:gameover()
end

function game:spawnEnemy(spawner)
    local enemyInstance = Entities.new("enemy", spawner.pos.x, spawner.pos.y)
    self.map:registerEntity(enemyInstance)
    enemyInstance:start()
    self.currentWave.spawnedEnemyCount = self.currentWave.spawnedEnemyCount + 1
end

function game:spawnEnemies(count)
    local spawners = self.map:getAllEntitiesWithTag("spawner")
    if spawners == nil then
        error("Failed to spawn enemies: No spawners found!")
    end

    self.currentWave.totalEnemies = count

    Timer.every(_local.timeBetweenEnemySpawns, function()
        self:spawnEnemy(spawners[love.math.random(1, #spawners)])
    end, count)
end

function game:spawnRandomVase(count)
    if count < 1 then
        return
    end
    for i=1, count do
        while true do
            local x = love.math.random(1, self.map.width)
            local y = love.math.random(1, self.map.height)
            local tileData = self.map:getTileAt(x, y, 2)
            if tileData == nil or not tileData.isSolid then
                local worldX, worldY = self.map:gridToWorldPos(x, y)
                local halfTileSize = math.floor(self.map.tileSize / 2)
                local instance = Entities.new("vase", worldX + halfTileSize, worldY + halfTileSize)
                self.map:registerEntity(instance)
                break
            end
        end
    end
end

function game:spawnRandomBoulders(count)
    if count < 1 then
        return
    end
    for i=1, count do
        while true do
            local x = love.math.random(1, self.map.width)
            local y = love.math.random(1, self.map.height)
            local tileData = self.map:getTileAt(x, y, 2)
            if tileData == nil or not tileData.isSolid then
                local worldX, worldY = self.map:gridToWorldPos(x, y)
                local halfTileSize = math.floor(self.map.tileSize / 2)
                local instance = Entities.new("boulder", worldX + halfTileSize, worldY + halfTileSize)
                self.map:registerEntity(instance)
                break
            end
        end
    end
end

function game:nextWave()
    self.currentWave.num = self.currentWave.num + 1
    self.currentWave.spawnedEnemyCount = 0
    self.totalEnemies = 0
    self:spawnEnemies(self.currentWave.num)
    self:spawnRandomVase(love.math.random(-1, 3))
    self:spawnRandomBoulders(love.math.random(-1, 3))
end

function game:gameover()
    Signal.emit("gameover")
    Timer.after(_local.timeBeforeRestart, function() self:restart() end)
end

function game:restart()
    Timer.clear()
    Gamestate.switch(game)
end

return game