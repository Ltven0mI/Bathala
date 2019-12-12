local Class = require "hump.class"
local Maf = require "core.maf"

local SpriteLoader = require "core.spriteloader"

local Grid = Class{
    init = function(self, width, depth, cellSize)
        self.width = width
        self.depth = depth
        self.cellSize = cellSize

        local totalWidth = (self.width+1) * self.cellSize
        local totalDepth = (self.depth+1) * self.cellSize

        local vertices = {
            {0, 0, 0, 0, 0, 1, 1, 1, 1}, -- Front Left
            {totalWidth, 0, 0, 1, 0, 1, 1, 1, 1}, -- Front Right
            {0, 0, totalDepth, 0, 1, 1, 1, 1, 1}, -- Back Left
            {totalWidth, 0, totalDepth, 1, 1, 1, 1, 1, 1} -- Back Right
        }
        local indices = {1, 2, 4, 4, 3, 1}--{1, 3, 4, 4, 2, 1}

        self.sprite = SpriteLoader.createSpriteFromVertices(vertices, indices, nil, true)
        self.shader = love.graphics.newShader([[
            varying vec4 vertexPos;

            #ifdef VERTEX
            vec4 position(mat4 transform_projection, vec4 vertex_position)
            {
                vertexPos = vertex_position;
                return transform_projection * vertex_position;
            }
            #endif
            #ifdef PIXEL
        
            vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
            {
                vec4 texcolor = Texel(tex, texture_coords);
                //frac(input.worldPos.x/_GridSpacing) < _GridThickness || frac(input.worldPos.y/_GridSpacing) < _GridThickness
                float xAlpha = 1-ceil(mod(vertexPos.x / 16 + 0.5f, 1)-(1.0f / 32));
                float zAlpha = 1-ceil(mod(vertexPos.z / 16 + 0.5f, 1)-(1.0f / 32));
                return texcolor * color * vec4(1, 1, 1, xAlpha + zAlpha);
            }
            
            #endif
        ]])
    end,
    __includes = {
    }
}

function Grid:draw(x, y, z)
    love.graphics.push("all")
    love.graphics.setShader(self.shader)
    self.sprite:draw(x-self.cellSize / 2, y, z - self.cellSize / 2)
    love.graphics.pop()
end

return Grid