local Class = require "hump.class"
local Tile = require "classes.tile"
local SpriteLoader = require "core.spriteloader"
local PathUtil = require "AssetBundle.PathUtil"

local SmartTile = Class{
    init = function(self, map, x, y, layerId)
        Tile.init(self, map, x, y, layerId)
    end,
    __includes={ Tile },

    spriteMeshFile="assets/meshes/tile_ground.obj",
    spriteImgFile="assets/images/missing_texture.png",
    spriteIsTransparent=false,

    noiseFrequency = 2,

    imagePath = nil,
    imageConditions = {}
}

function SmartTile:onLoaded()
    Tile.onLoaded(self)
    local imageParts = {}
    for _, item in ipairs(love.filesystem.getDirectoryItems(self.imagePath)) do
        local fullPath = PathUtil.join(self.imagePath, item)
        if love.filesystem.getInfo(fullPath, "file") then
            local fileName, ext = PathUtil.splitExt(item)
            imageParts[fileName] = love.graphics.newImage(fullPath)
        end
    end
    self.imageParts = imageParts
    self.compositeImages = {}
end

-- Returns true if the condition fits with the neighbours otherwise returns false
function SmartTile:checkNeighboursMatchCondition(neighbours, condition)
    for x=-1, 1 do
        for z=-1, 1 do
            local neighbourData = neighbours[x][z]
            local neighbourName = (neighbourData ~= nil) and neighbourData.__name or nil
            local conditionValue = condition.neighbours[(x+2) + (2-(z+1))*3]
            if (conditionValue == 2 and neighbourName == self.__name) or
            (conditionValue == 1 and neighbourName ~= self.__name) then
                return false
            end
        end
    end
    return true
end

function SmartTile:getMatchingConditionalKeys(neighbours, noise)
    local conditionalKeys = {}
    for k, condition in ipairs(self.imageConditions) do
        local noiseRange = condition.noiseRange
        if noiseRange == nil or (noiseRange.min < noise and noise <= noiseRange.max) then
            if self:checkNeighboursMatchCondition(neighbours, condition) then
                table.insert(conditionalKeys, k)
            end
        end
    end
    return conditionalKeys
end

function SmartTile:getCompositeImageKey(conditionalKeys)
    local result = ""
    for _, key in ipairs(conditionalKeys) do
        result = result .. string.char(key)
    end
    return result
end

function SmartTile:createCompositeImage(conditionalKeys)
    -- Get Image Parts from condition keys
    local imageParts = {}
    for _, conditionalKey in ipairs(conditionalKeys) do
        local imageName = self.imageConditions[conditionalKey].imageName
        local imagePart = self.imageParts[imageName]
        if not imagePart then
            error(string.format("Unknown imagepart '%s' from tile '%s'", imageName, self.__name))
        end
        table.insert(imageParts, imagePart)
    end

    local canvas = love.graphics.newCanvas(imageParts[1]:getDimensions())
    canvas:renderTo(function()
        love.graphics.setColor(1, 1, 1, 1)
        for _, imagePart in ipairs(imageParts) do
            love.graphics.draw(imagePart, 0, 0)
        end
    end)
    return love.graphics.newImage(canvas:newImageData())
end

function SmartTile:getImageMatchingNeighbours(neighbours)
    local noise = love.math.noise(self.gridX*self.noiseFrequency+0.12345, self.gridZ*self.noiseFrequency+0.12345)
    local matchingConditionalKeys = self:getMatchingConditionalKeys(neighbours, noise)
    local compositeImageKey = self:getCompositeImageKey(matchingConditionalKeys)
    local compositeImage = self.compositeImages[compositeImageKey]
    if compositeImage == nil then
        compositeImage = self:createCompositeImage(matchingConditionalKeys)
        self.compositeImages[compositeImageKey] = compositeImage
    end
    return compositeImage
end

function SmartTile:onNeighboursChanged()
    local neighbours = self.map:getTileNeighboursAt(self.gridX, self.gridY, self.gridZ)
    local compositeImage = self:getImageMatchingNeighbours(neighbours)
    if compositeImage then
        self.sprite:setTexture(compositeImage)
    end
end

return SmartTile