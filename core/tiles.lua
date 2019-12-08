local PathUtil = require "AssetBundle.PathUtil"

local m = {}
local _local = {}

local _defaultPath = "assets/tiles/"
_local.path = _defaultPath

_local.loadedTiles = {}


-- [[ Debug Functions ]] --

local function printInfo(str, ...)
    print("[info] "..tostring(str), ...)
end
local function printWarn(str, ...)
    print("[warn] "..tostring(str), ...)
end
-- \\ End Debug Functions // --


-- [[ Exposed Functions ]] --

function m.loadTiles()
    printInfo(string.format("Loading Tiles from '%s'...", _local.path))
    _local.loadTilesFrom(_local.path)
    printInfo("Finished loading Tiles!")
end

function m.new(tileName, ...)
    local tile = _local.loadedTiles[tileName]
    if tile == nil then
        error(string.format("Failed to create instance of tile: No tile with name '%s'", tileName), 2)
    end
    return tile(...)
end

function m.get(tileName)
    local tile = _local.loadedTiles[tileName]
    if tile == nil then
        error(string.format("Failed to get tile: No tile with name '%s'", tileName), 2)
    end
    return tile
end

--[[
    Returns a table containing all tiles thats name matches the pattern.
]]
function m.getTilesMatchingPattern(pattern)
    if pattern == nil or pattern:len() == 0 then
        pattern = ".*"
    end
    local matchedTiles = {}
    for name, tile in pairs(_local.loadedTiles) do
        if name:match(pattern) then
            table.insert(matchedTiles, tile)
        end
    end
    return matchedTiles
end

function m.setDefaultPath(path)
    if type(path) ~= "string" then
        error(string.format("setDefaultPath() accepts type 'string' not '%s'", type(path)), 2)
    end
    _local.path = PathUtil.cleanPath(path)
end
-- \\ End Exposed Functions // --


-- [[ Local Functions ]] --

function _local.loadTileFromFile(path, name)
    local chunk, err = love.filesystem.load(path)
    if chunk == nil then
        return false, err
    end

    local success, result_or_err = pcall(chunk)
    if not success then
        return false, result_or_err
    end

    if type(result_or_err) ~= "table" then
        return false, string.format("File returned type '%s' instead of 'table'", type(result_or_err))
    end

    local root, baseName = PathUtil.split(path)
    local fileName, ext = PathUtil.splitExt(baseName)

    local tileName = result_or_err.__name or fileName

    if _local.loadedTiles[tileName] ~= nil then
        return false, string.format("Tile already exists with the name '%s'", tileName)
    end
    
    result_or_err.__name = tileName
    _local.loadedTiles[tileName] = result_or_err

    if result_or_err.onLoaded then
        result_or_err:onLoaded()
    end

    return true, tileName
end

function _local.loadTilesFrom(dirPath)
    local directoryItems = love.filesystem.getDirectoryItems(_local.path)
    for _, item in ipairs(directoryItems) do
        local fullPath = PathUtil.join(dirPath, item)
        local info = love.filesystem.getInfo(fullPath)
        if info.type == "directory" then
            _local.loadTilesFrom(fullPath)
        elseif info.type == "file" then
            local success, name_or_err = _local.loadTileFromFile(fullPath)
            if not success then
                printWarn(string.format("Failed to load tile '%s' : %s", fullPath, name_or_err))
            end
            printInfo(string.format("Successfully loaded tile '%s' from '%s'", name_or_err, fullPath))
        else
            printInfo(string.format("Ignoring unknown directory item '%s'", fullPath))
        end
    end
end
-- \\ End Local Functions // --

return m