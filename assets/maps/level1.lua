local m = {}

m.width = 16
m.height = 16

m.grid = {}
for x=1, m.width do
    m.grid[x] = {}
    for y=1, m.height do
        m.grid[x][y] = love.math.random(0, 1)
    end
end

return m