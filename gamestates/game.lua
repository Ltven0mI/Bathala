local Camera = require "hump.camera"
local Signal = require "hump.signal"
local Vector = require "hump.vector"
local Timer = require "hump.timer"
local Gamestate = require "hump.gamestate"

local AssetBundle = require "AssetBundle"
local Player = require "classes.player"
local Map = require "classes.map"

local game = {}

game.camera = nil
game.player = nil
game.tileset = nil
game.map = nil

local assets = AssetBundle("assets", {
    maps={
        level1="mapExport.lua"
    },
    entities={
        "boulder.lua",
        "vase.lua",
        "curse_powerup.lua",
        "sinigang_powerup.lua"
    },
    "player/player_temp.png",
    "entities/enemy.lua",
    "tilesets/default_tileset.lua"
})

function game:enter()
    AssetBundle.load(assets)

    self.camera = Camera(0, 0)
    self.camera:zoomTo(4)

    self.tileset = assets.tilesets.default_tileset
    self.tileset.load()

    self.map = Map(assets.maps.level1, self.tileset)
    self.map:generateGrid()
    
    self.player = Player(assets.player.player_temp, 0, 0, 10, 16)
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

    self.currentWave = 0
    self.enemyCount = 0

    self.luckydrops = {
        assets.entities.curse_powerup,
        assets.entities.sinigang_powerup
    }

    self:nextWave()
end

function game:leave()
    AssetBundle.unload(assets)

    self.camera = nil
    self.player = nil

    self.tileset.unload()
    self.tileset = nil

    self.map = nil

    Signal.clear("vase-smashed")
    Signal.clear("statue-heal")
    Signal.clear("enemy-died")
    Signal.clear("statue-died")
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

    -- local screenW, screenH = love.graphics.getDimensions()
    -- love.graphics.line(0, math.floor(screenH / 2), screenW, math.floor(screenH / 2))
    -- love.graphics.line(math.floor(screenW / 2), 0, math.floor(screenW / 2), screenH)
end

function game:mousepressed(x, y, btn)
    if btn == 1 then
        local worldX, worldY = self.camera:worldCoords(x, y)
        local dir = (Vector(worldX, worldY) - self.player.pos):normalized()
        self.player:attack(dir)
    end
end

function game:vase_smashed(x, y)
    local rand = love.math.random(1, 4)
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
    self.enemyCount = self.enemyCount - 1
    print("EnemyDied! Enemies left: "..self.enemyCount)
    if self.enemyCount == 0 then
        Timer.after(3, function() self:nextWave() end)
    end
end

function game:statue_died(statue)
    self:gameover()
end

function game:spawnEnemies(count)
    local spawner = self.map:findEntityOfType("spawner")
    if spawner == nil then
        error("Failed to spawn enemies: No spawner found!")
    end

    for i=1, count do
        local enemyInstance = assets.entities.enemy(spawner.pos.x, spawner.pos.y)
        self.map:registerEntity(enemyInstance)
        enemyInstance:start()
        self.enemyCount = self.enemyCount + 1
    end
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
                local instance = assets.entities.vase(worldX, worldY)
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
                local instance = assets.entities.boulder(worldX, worldY)
                self.map:registerEntity(instance)
                break
            end
        end
    end
end

function game:nextWave()
    self.currentWave = self.currentWave + 1
    self:spawnEnemies(self.currentWave)
    self:spawnRandomVase(love.math.random(-1, 3))
    self:spawnRandomBoulders(love.math.random(-1, 3))
end

function game:gameover()
    Signal.emit("gameover")
    Timer.after(3, function() self:restart() end)
end

function game:restart()
    self.map = Map(assets.maps.level1, self.tileset)
    self.map:generateGrid()
    
    self.player = Player(assets.player.player_temp, 0, 0, 10, 16)
    self.player:setMap(self.map)

    local playerSpawn = self.map:findEntityOfType("player_spawn")
    if playerSpawn then
        self.player.pos.x = playerSpawn.pos.x
        self.player.pos.y = playerSpawn.pos.y
    end

    self.currentWave = 0
    self.enemyCount = 0

    self:nextWave()
end

return game