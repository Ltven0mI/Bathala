local UTF8 = require "utf8"

local m = {}

local _const = {}
_const.height = 24

local _local = {}
_local.text = ""
_local.exposedVariables = {}
_local.msgTable = {}
_local.enabled = false

love.keyboard.setKeyRepeat(true)

function m.expose(key, var)
    _local.exposedVariables[key] = var
end

function m.getIsEnabled()
    return _local.enabled
end

function m.update(dt)
    if not _local.enabled then return end

    for i, entry in ipairs(_local.msgTable) do
        entry.ttl = entry.ttl - dt
        if entry.ttl <= 0 then
            table.remove(_local.msgTable, i)
        end
    end
end

function m.draw()
    if not _local.enabled then return end

    local screenW = love.graphics.getWidth()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, screenW, _const.height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 2, 2, screenW - 4, _const.height - 4)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(_local.text, 4, 4)

    for i, entry in ipairs(_local.msgTable) do
        love.graphics.setColor(entry.bgColor)
        love.graphics.rectangle("fill", 2, i * _const.height, screenW - 4, _const.height - 4)
    
        love.graphics.setColor(entry.textColor)
        love.graphics.print(entry.msg, 4, i * _const.height + 4)
    end
end

function m.keypressed(key, isRepeat)
    if key == "`" and love.keyboard.isDown("lctrl") then
        _local.enabled = not _local.enabled
    end
    
    if not _local.enabled then return end

    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = UTF8.offset(_local.text, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            _local.text = string.sub(_local.text, 1, byteoffset - 1)
        end
    elseif key == "return" then
        local text = _local.text
        _local.text = ""
        local success, msg = m.processCommandLine(text)
        if not success and msg then
            m.displayMsg(msg, {1, 0, 0, 1}, {1, 1, 1, 1})
        end
    end
end

function m.textinput(text)
    if not _local.enabled then return end

    _local.text = _local.text .. text
end

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function m.processCommandLine(text)
    local args = split(text, "%s")
    if args[1] == nil then
        return true
    end
    local var = _local.exposedVariables[args[1]]
    if var == nil then
        return false, string.format("Unknown exposed variable '%s'", args[1])
    end

    local vType = type(var)
    if vType == "function" then
        table.remove(args, 1)
        return var(unpack(args))
    else
        return false, string.format("Unknown variable type '%s'", vType)
    end
end

function m.displayMsg(msg, bgColor, textColor, ttl)
    ttl = ttl or 5
    table.insert(_local.msgTable, {
        msg=msg,
        bgColor=bgColor,
        textColor=textColor,
        ttl=ttl
    })
end

return m