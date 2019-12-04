local Lewd = require "core.lewd"
local UTF8 = require "utf8"

local _local = {}
function _local.new()
    local t = Lewd.element{x=0, y=0, w="100%", h="100%", parent=nil}
    
    t.tileSelectionLayout = Lewd.layout{w=250, h=187, layoutType="vertical", padding={right=2, bottom=2}, horizontalAlignment="right", verticalAlignment="bottom", parent=t}
    t.tileSelectionResultElement = Lewd.element{w="100%", h=170, parent=t.tileSelectionLayout}
    t.tileSelectionResultElement.draw = function(self, x, y)
        love.graphics.setColor(1, 1, 1, 1)
        local realW, realH = self:getRealSize()
        _local.drawBorder(x, y, realW, realH)
        return Lewd.element.draw(self, x, y)
    end
    t.tileSelectionSearchBar = Lewd.textbox{w="100%", h=17, value="", parent=t.tileSelectionLayout}

    return t
end


-- [[ Drawing Functions ]] --

function _local.drawBorder(x, y, w, h)
    love.graphics.rectangle("fill", x, y, w, 1) -- Top
    love.graphics.rectangle("fill", x, y+h-1, w, 1) -- Bottom
    love.graphics.rectangle("fill", x, y, 1, h) -- Left
    love.graphics.rectangle("fill", x+w-1, y, 1, h) -- Right
end
-- \\ End Drawing Functions // --


-- [[ Custom Lewd Elements ]] --

Lewd.core.newElementType("textbox", {
    __extends="layout",
    init = function(self, data)
        data = data or {}
        Lewd.layout.init(self, data)

        self.value = data.value or ""
        self.layoutType = "horizontal"

        self.label = Lewd.label{text=self.value, padding={left=4}, wrapContent=true, verticalAlignment="centre", ignoresInput=true, parent=self}
        self.cursor = Lewd.element{w=2, h="80%", padding={left=1}, isVisible=false, ignoresInput=true, parent=self}
        self.cursor.draw = function(element, x, y)
            if math.floor(love.timer.getTime() * 3.5) % 2 ~= 1 then
                local realW, realH = element:getRealSize()
                love.graphics.rectangle("fill", x, y, realW, realH)
            end
            return Lewd.element.draw(element, x, y)
        end
    end,
    setValue = function(self, value, ignoreCallback)
        self.value = value
        self.label:setText(value)
        if not ignoreCallback and self.onValueChanged then
            self:onValueChanged(value)
        end
    end,
    getValue = function(self)
        return self.value
    end,
    draw = function(self, x, y)
        local realW, realH = self:getRealSize()
        love.graphics.setColor(1, 1, 1, 1)
        _local.drawBorder(x, y-1, realW, realH+1)
        return Lewd.layout.draw(self, x, y)
    end,
    onKeyPressed = function(self, key, scancode, isRepeat)
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = UTF8.offset(self:getValue(), -1)
     
            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                local newText = string.sub(self:getValue(), 1, byteoffset - 1)
                self:setValue(newText)
            end
        elseif key == "return" then
            Lewd.core.setSelectedElement(nil)
        end
    end,
    onTextInput = function(self, text)
        self:setValue(self:getValue() .. text)
    end,
    onFocused = function(self)
        self.cursor:setIsVisible(true)
    end,
    onLostFocus = function(self)
        self.cursor:setIsVisible(false)
    end
})

Lewd.core.registerNewElementTypes()
-- \\ End Custom Lewd Elements // --

return setmetatable({}, {__call = function(_, ...) return _local.new(...) end})