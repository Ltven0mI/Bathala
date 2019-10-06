local PathUtil = require "AssetBundle.PathUtil"
local AssetTable = require "AssetBundle.AssetTable"
local AssetCache = require "AssetBundle.AssetCache"
local AssetLoader = require "AssetBundle.AssetLoader"

local m = {}

function m.newBundle(basePath, dirtyAssetTable)
  local mt = {
    isLoaded=false,
    basePath=basePath or "",
    assetTable=AssetTable.clean(dirtyAssetTable)
  }
  
  mt.__index=function(t, k)
    assert(mt.isLoaded, "Attempted to access assets from an un-loaded AssetBundle!")
  end
  
  return setmetatable({}, mt)
end

local function loadAsset(bundleID, path)
  local dir, basename = PathUtil.split(path)

  if basename == "*" then
    -- Basename was a wildcard so load an return all assets in the directory
    local results = {}
    local dirItems = love.filesystem.getDirectoryItems(dir)
    for _, v in ipairs(dirItems) do
      local asset = loadAsset(bundleID, PathUtil.join(dir, v))
      local filename, _ = PathUtil.splitExt(v)
      results[filename] = asset
    end

    return results
  end

  local asset = AssetCache.getItemValue(path)
  if asset == nil then
    local asset_or_nil, err = AssetLoader.loadFromFile(path)
    if asset_or_nil == nil then
      error(string.format("Failed to load asset '%s': %s", path, err))
    end
    asset = asset_or_nil
    AssetCache.addItem(path, asset)
  end
  AssetCache.addUser(path, bundleID)

  return asset
end

function m.load(bundle)
  -- Access Bundle's metatable and error if already loaded
  local mt = getmetatable(bundle)
  assert(mt.isLoaded == false, string.format("Attempted to load an already loaded AssetBundle"))
  
  local assetTable = mt.assetTable
  
  local function loadAssetTable(assetTable, path, bundleTable, bundleID)
    for k, v in pairs(assetTable) do
      if type(v) == "table" then
        bundleTable[k] = {}
        loadAssetTable(v, PathUtil.join(path, k), bundleTable[k], bundleID)
      else
        local asset = loadAsset(bundleID, PathUtil.join(path, v))
        bundleTable[k] = asset
      end
    end
  end
  
  -- Load assets from assetTable into the Bundle
  -- using the meta-table as it's bundleID.
  loadAssetTable(assetTable, mt.basePath, bundle, mt)

  mt.isLoaded = true
end

local function __call(t, ...)
  return m.newBundle(...)
end

return setmetatable(m, {__call=__call})