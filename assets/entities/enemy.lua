local Class = require "hump.class"
local Vector = require "hump.vector"
local Signal = require "hump.signal"

local Entity = require "classes.entity"

local DesecratorProjectile = require "assets.entities.desecrator_projectile"

local Enemy = Class{
    init = function(self, x, y)
        Entity.init(self, x, y, 16, 24)
        self.target = nil
        self.targetStatue = nil
        self.path = nil
        self.currentNode = nil
        self.health = 2
        self.attackTimer = 0
    end,
    __includes = {
        Entity
    },
    speed = 32,
    stoppingDistance = 16,
    timeBetweenAttacks = 3,
    img = love.graphics.newImage("assets/desecrator/desecrator_temp.png"),
    type = "enemy"
}

local function _newPriorityQueue()
    return {
        queue = {},
        put = function(self, pos, priority)
            table.insert(self.queue, {pos=pos, priority=priority})
            table.sort(self.queue, function(a, b) return a.priority < b.priority end)
        end,
        get = function(self)
            return table.remove(self.queue, 1)
        end,
        isEmpty = function(self)
            return (#self.queue == 0)
        end,
    }
end

function Enemy:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    if self.health == 0 then
        self.map:unregisterEntity(self)
        Signal.emit("enemy-died", self)
    end
end

function Enemy:start()
    self.targetStatue = self.map:findEntityOfType("statue")
    if self.targetStatue then
        local statue = self.targetStatue
        local statueBasePos = statue.pos + statue.baseOffset
        local randRot = love.math.random(1, 360)
        local randOffset = Vector(statue.w + self.stoppingDistance, 0):rotated(math.rad(randRot))
        self:setTarget((statueBasePos + randOffset):unpack())
    end
end

function Enemy:calculateCost(current, next)
    local tileData = self.map:getTileAt(next.x, next.y, 2)
    return ((tileData and tileData.isSolid) and 6 or 1)
end

function Enemy:getNeighboursAt(x, y)
    local possibleNeighbours = {
        {x=x-1, y=y},
        {x=x+1, y=y},
        {x=x, y=y-1},
        {x=x, y=y+1}
    }

    local neighbours = {}
    for _, neighbour in ipairs(possibleNeighbours) do
        local groundTileData = self.map:getTileAt(neighbour.x, neighbour.y, 1)
        local tileData = self.map:getTileAt(neighbour.x, neighbour.y, 2)
        if groundTileData ~= nil and (tileData == nil or tileData.isSolid == false) then
            table.insert(neighbours, neighbour)
        end
    end

    return neighbours
end

function Enemy:updatePath()
    local nodeGrid = {}
    for x=1, self.map.width do
        nodeGrid[x] = {}
        for y=1, self.map.height do
            nodeGrid[x][y] = nil
        end
    end

    local startX, startY = self.map:worldToGridPos(self.pos:unpack())
    local goalX, goalY = self.map:worldToGridPos(self.target:unpack())

    local frontier = _newPriorityQueue()
    frontier:put({x=startX, y=startY}, 0)

    nodeGrid[startX][startY] = {
        x=startX,
        y=startY,
        came_from = nil,
        cost_so_far = 0,
    }

    local shortestDist = math.huge
    local closestNode = nil

    while not frontier:isEmpty() do
        local current = frontier:get()
        local currentNode = nodeGrid[current.pos.x][current.pos.y]

        local distToGoal = Vector(goalX - currentNode.x, goalY - currentNode.y):len()
        if distToGoal < shortestDist then
            shortestDist = distToGoal
            closestNode = currentNode
        end
        
        if current.pos.x == goalX and current.pos.y == goalY then
            break
        end

        local neighbors = self:getNeighboursAt(current.pos.x, current.pos.y)

        for _, next in ipairs(neighbors) do
            local nextNode = nodeGrid[next.x][next.y]
            if nextNode == nil then
                nodeGrid[next.x][next.y] = {
                    x=next.x,
                    y=next.y,
                    came_from = nil,
                    cost_so_far = math.huge,
                }
                nextNode = nodeGrid[next.x][next.y]
            end
            local new_cost = currentNode.cost_so_far + self:calculateCost({x=current.pos.x, y=current.pos.y}, next)
            if nextNode.cost_so_far == nil or new_cost < nextNode.cost_so_far then
                nextNode.cost_so_far = new_cost
                local priority = new_cost + 0 --[[ heuristic(goal, next) ]]
                frontier:put({x=next.x, y=next.y}, priority)
                nextNode.came_from = currentNode
            end
        end
    end

    -- * Debug value
    self.nodeGrid = nodeGrid

    -- local goalNode = nodeGrid[goalX][goalY]
    -- if goalNode == nil then
    --     if 
    --     -- Handle it not reaching the goal
    --     error("Failed to reach goal: "..tostring(goalX)..", "..tostring(goalY))
    -- end

    goalNode = closestNode

    self.path = {}
    local currentNode = goalNode
    while currentNode.came_from do
        table.insert(self.path, 1, currentNode)
        currentNode = currentNode.came_from
    end

    -- for k, v in ipairs(self.path) do
    --     print(k, v.x, v.y)
    -- end


    -- frontier = PriorityQueue()
    -- frontier.put(start, 0)
    -- came_from = {}
    -- cost_so_far = {}
    -- came_from[start] = None
    -- cost_so_far[start] = 0

    -- while not frontier.empty():
    -- current = frontier.get()

    -- if current == goal:
    --     break
    
    -- for next in graph.neighbors(current):
    --     new_cost = cost_so_far[current] + graph.cost(current, next)
    --     if next not in cost_so_far or new_cost < cost_so_far[next]:
    --         cost_so_far[next] = new_cost
    --         priority = new_cost + heuristic(goal, next)
    --         frontier.put(next, priority)
    --         came_from[next] = current
end

function Enemy:setTarget(x, y)
    self.target = Vector(x, y)
    self:updatePath()
    self:nextNode()
end

function Enemy:nextNode()
    self.currentNode = table.remove(self.path, 1)
end

function Enemy:update(dt)
    if self.targetStatue and self.targetStatue.health > 0 then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer > self.timeBetweenAttacks then
            self.attackTimer = 0
            local dir = (self.targetStatue.pos - self.pos):normalized()
            self:attack(dir)
        end
    end


    if self.currentNode then
        local nodeWorldX, nodeWorldY = self.map:gridToWorldPos(self.currentNode.x, self.currentNode.y)

        local halfTileSize = math.floor(self.map.tileSize / 2)
        local halfEnemyW, halfEnemyH = math.floor(self.w / 2), math.floor(self.h / 2)
        local targetX = nodeWorldX + halfTileSize-- - halfEnemyW
        local targetY = nodeWorldY + halfTileSize-- - self.h

        local delta = Vector(targetX, targetY) - self.pos
        self.pos = self.pos + delta:normalized() * math.min(delta:len(), self.speed * dt)
        if delta:len() <= 0 then
            self:nextNode()
        end
    end

    if love.keyboard.isDown("space") then
        self:start()
    end
end

function Enemy:draw()
    local halfEnemyW, halfEnemyH = math.floor(self.w / 2), math.floor(self.h / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, halfEnemyW, self.h)
    -- self:drawCollisionBox()

    if self.target then
        -- love.graphics.setColor(1, 0, 0, 1)
        -- love.graphics.circle("line", self.target.x, self.target.y, 4)
        -- love.graphics.line(self.pos.x, self.pos.y, self.target.x, self.target.y)

        -- for _, node in ipairs(self.path) do
        --     local halfTileSize = math.floor(self.map.tileSize / 2)
        --     local drawX, drawY = (node.x-1) * self.map.tileSize, (node.y-1) * self.map.tileSize
        --     love.graphics.setColor(1, 1, 1, 1)
        --     love.graphics.rectangle("fill", drawX + halfTileSize - 2, drawY + halfTileSize - 2, 4, 4)
        -- end

        -- for x=1, self.map.width do
        --     for y=1, self.map.height do
        --         local node = self.nodeGrid[x][y]
        --         if node ~= nil then
        --             local halfTileSize = math.floor(self.map.tileSize / 2)
        --             local drawX, drawY = (x-1) * self.map.tileSize, (y-1) * self.map.tileSize
        --             love.graphics.setColor(1, 1, 1, 1)
        --             love.graphics.rectangle("fill", drawX + halfTileSize - 2, drawY + halfTileSize - 2, 4, 4)
        --             love.graphics.setColor(0, 0, 1, 1)
        --             love.graphics.print(node.cost_so_far, drawX, drawY)

        --             if node.came_from ~= nil then
        --                 local drawX2, drawY2 = (node.came_from.x-1) * self.map.tileSize, (node.came_from.y-1) * self.map.tileSize
        --                 love.graphics.setColor(0, 1, 0, 1)
        --                 love.graphics.line(drawX + halfTileSize, drawY + halfTileSize, drawX2 + halfTileSize, drawY2 + halfTileSize)
        --             end
        --         end
        --     end
        -- end
    end
end

function Enemy:intersectPoint(x, y)
    local halfEnemyW, halfEnemyH = math.floor(self.w / 2), math.floor(self.h / 2)
    return (
        x >= self.pos.x-halfEnemyW and x < self.pos.x + halfEnemyW and
        y >= self.pos.y - self.h and y < self.pos.y + halfEnemyH
    )
end

function Enemy:attack(dir)
    local halfW = math.floor(self.w / 2)
    local halfH = math.floor(self.h / 2)
    local projectileInstance = DesecratorProjectile(self.pos.x + halfW, self.pos.y + halfH, dir)
    self.map:registerEntity(projectileInstance)
end

return Enemy