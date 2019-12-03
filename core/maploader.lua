local Map = require "classes.map"

local m = {}

--[[
    Returns a new instance of Map with data from the specified file on success
    otherwise returns nil and an error message.
]]
function m.loadFromFile(filePath)
    local info = love.filesystem.getInfo(filePath, "file")
    if not info then
        return nil, string.format("Failed loading Map from file '%s' : No file exists at that path.", filePath)
    end

    local chunk, err = love.filesystem.load(filePath)
    if not chunk then
        return nil, string.format("Failed loading Map from file '%s' : %s", err)
    end

    local success, result_or_err = pcall(chunk)
    if not success then
        return nil, string.format("Failed to interperate MapData from '%s' : %s", filePath, result_or_err)
    end

    return Map(result_or_err)
end

return m