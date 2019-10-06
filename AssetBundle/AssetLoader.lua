local PathUtil = require "AssetBundle.PathUtil"

local m = {}

local function _loader_lua(path)
    local chunk, err = love.filesystem.load(path)
    if chunk == nil then
        return nil, err
    end
    return chunk() or true
end

m.loaders = {
    [".png"] = love.graphics.newImage,
    [".lua"] = _loader_lua
}

function m.loadFromFile(path)
    local dir, basename = PathUtil.split(path)
    local filename, ext = PathUtil.splitExt(basename)

    local loader = m.loaders[ext]
    if loader == nil then
        return nil, string.format("No loader found for '%s' files.", ext)
    end

    return loader(path)
end

return m