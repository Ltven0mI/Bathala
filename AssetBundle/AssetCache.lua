local m = {}

local _cache = {}

function m.addItem(key, value)
    assert(_cache[key]==nil, string.format(
        "Attempted to cache an item with the key '%s'. An item already exists with this key.", key
    ))

    _cache[key] = {
        value=value,
        users={}
    }
end

function m.getItemValue(key)
    local item = _cache[key]
    return item and item.value or nil
end

function m.addUser(key, user)
    local item = _cache[key]
    assert(item~=nil, string.format(
        "Failed to add user to a non existing cache item '%s'", key
    ))
    item.users[user] = true
end

function m.removeUser(key, user)
    local item = _cache[key]
    print(tostring(item.users[user]))
    assert(item~=nil, string.format(
        "Failed to remove user from a non existing cache item '%s'", key
    ))

    assert(item.users[user]==true, string.format(
        "Failed to remove user '%s' from the cache item with key '%s' as the user was not yet added.", user, key
    ))

    item.users[user] = nil
end

function m.removeUnusedItems()
    for key, item in pairs(_cache) do
        -- Check if item has users.
        local isItemInUse = false
        for _, _ in pairs(item.users) do
            isItemInUse = true
            break
        end

        if not isItemInUse then
            -- Remove item as it no longer has users.
            item.users = nil
            item.value = nil
            _cache[key] = nil
        end
    end
end

-- ! TEMP FUNCTION
function m.getCache()
    return _cache
end

return m