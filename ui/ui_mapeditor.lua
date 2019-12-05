local Lewd = require "core.lewd"
local UTF8 = require "utf8"

local _local = {}
function _local.new()
    local t = Lewd.element{x=0, y=0, w="100%", h="100%", parent=nil}
    
    t.tileSelectionLayout = Lewd.layout{w=250, h=187, layoutType="vertical", padding={right=2, bottom=2}, horizontalAlignment="right", verticalAlignment="bottom", parent=t}
    t.tileSelectionResultGrid = Lewd.gridlayout{w="100%", h=170, entryWidth=32, entryHeight=64, entryPadding={top=8, left=8, bottom=8}, parent=t.tileSelectionLayout}
    t.tileSelectionResultGrid.draw = function(self, x, y)
        love.graphics.setColor(1, 1, 1, 1)
        local realW, realH = self:getRealSize()
        _local.drawBorder(x, y, realW, realH)
        return Lewd.gridlayout.draw(self, x, y)
    end
    t.tileSelectionResultGrid.drawEntry = function(self, entry, element, x, y, w, h)
        local offsetY = 0

        -- [[ Set color based on whether the tile is selected or not ]] --
        if entry == self.selectedEntry then
            love.graphics.setColor(1, 1, 1, 1)
        elseif element.isHovered then
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            offsetY = -2
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        _local.drawBorder(x, y + offsetY, w+2, h+2)
        
        if entry == self.selectedEntry then
            love.graphics.rectangle("fill", x-1, y+h+4 + offsetY, w+4, 2)
        end

        if entry.icon then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(entry.icon, x+1, y+1 + offsetY, 0, 2, 2)
        end
    end
    t.tileSelectionSearchBar = Lewd.textbox{w="100%", h=17, cursorH=12, value="", placeholder="Search Tiles", parent=t.tileSelectionLayout}

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
        self.placeholder = data.placeholder or ""
        self.layoutType = "horizontal"

        self.label = Lewd.label{text=self.value, padding={left=4}, wrapContent=true, verticalAlignment="top", ignoresInput=true, parent=self}
        self.placeholderLabel = Lewd.label{text=self.placeholder, style={fg_color={0.5, 0.5, 0.5, 1}}, padding={left=4}, wrapContent=true, verticalAlignment="top", ignoresInput=true, isVisible=false, parent=self}
        self.cursor = Lewd.element{w=2, h=data.cursorH or "100%", padding={left=1}, verticalAlignment="centre", isVisible=false, ignoresInput=true, parent=self}
        self.cursor.draw = function(element, x, y)
            if math.floor(love.timer.getTime() * 3.5) % 2 ~= 1 then
                local realW, realH = element:getRealSize()
                love.graphics.rectangle("fill", x, y, realW, realH)
            end
            return Lewd.element.draw(element, x, y)
        end

        self:setValue(self.value, true)
    end,
    setValue = function(self, value, ignoreCallback)
        self.value = value
        self.label:setText(value)
        self:updateLabelVisibility()
        if not ignoreCallback and self.onValueChanged then
            self:onValueChanged(value)
        end
    end,
    getValue = function(self)
        return self.value
    end,
    updateLabelVisibility = function(self)
        local showPlaceholder = ((self.value == nil or self.value:len() == 0) and not self.isSelected)
        self.label:setIsVisible(not showPlaceholder)
        self.placeholderLabel:setIsVisible(showPlaceholder)
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
        self:updateLabelVisibility()
    end,
    onLostFocus = function(self)
        self.cursor:setIsVisible(false)
        self:updateLabelVisibility()
    end
})

Lewd.core.newElementType("gridlayout", {
    __extends="element",
    init = function(self, data)
        data = data or {}
        Lewd.element.init(self, data)

        self.entryWidth = data.entryWidth or Lewd.style.unit
        self.entryHeight = data.entryHeight or Lewd.style.unit

        self.entryPadding = data.entryPadding or {}
        self.entryPadding.left = self.entryPadding.left or 0
        self.entryPadding.right = self.entryPadding.right or 0
        self.entryPadding.top = self.entryPadding.top or 0
        self.entryPadding.bottom = self.entryPadding.bottom or 0

        self.rows = data.rows
        self.columns = data.columns
        self:setEntries(data.entries or {}, true)
    end,
    setSelectedEntry = function(self, entry)
        self.selectedEntry = entry
        if self.onSelectedEntryChanged then
            self:onSelectedEntryChanged(entry)
        end
    end,
    setEntries = function(self, entries)
        self.entries = entries
        local childCount = #self.children
        local entryCount = #self.entries

        if childCount < entryCount then
            -- Need to add more elements
            for i=childCount+1, entryCount do
                local element = Lewd.element{w=self.entryWidth, h=self.entryHeight, padding=self.entryPadding, parent=self}
                element.entryID = i
                element.draw = function(element, x, y)
                    if element.parent.drawEntry then
                        local realW, realH = element:getRealSize()
                        element.parent:drawEntry(element.parent.entries[element.entryID], element, x, y, realW, realH)
                    end
                    return Lewd.element.draw(element, x, y)
                end
                element.onClick = function(element)
                    self:setSelectedEntry(element.parent.entries[element.entryID])
                end
            end
        else
            -- Need to remove elements
            while #self.children > entryCount do
                self:removeChild(self.children[entryCount + 1])
            end
        end
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        local childWidthSum, childHeightSum = 0, 0
        local rowWidth, columnHeight = 0, 0
        for i, child in ipairs(self.children) do
            if child.isVisible then
                local realChildPaddedW, realChildPaddedH = child:getRealPaddedSize()
                local realChildPadding = child:getRealPadding()

                local offsetX, offsetY = 0, 0
                if rowWidth + realChildPaddedW > realW then
                    -- This is when it moves to the next column
                    childWidthSum = math.max(childWidthSum, rowWidth)
                    childHeightSum = childHeightSum + columnHeight
                    rowWidth = 0
                    columnHeight = 0

                    if childHeightSum + realChildPaddedH > realH then
                        -- Hit the last row
                        break
                    end
                end

                offsetX = rowWidth + realChildPadding.left
                offsetY = childHeightSum + realChildPadding.top

                local offsetWidth, offsetHeight = child:draw(x + offsetX, y + offsetY)

                rowWidth = rowWidth + offsetWidth
                columnHeight = math.max(columnHeight, offsetHeight)
            end
        end
        childHeightSum = childHeightSum + columnHeight

        if self.wrapContent then
            realW = childWidthSum
            realH = childHeightSum
        end

        self:updateZoneEntry(x, y, realW, realH)

        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end
})

Lewd.core.registerNewElementTypes()
-- \\ End Custom Lewd Elements // --

return setmetatable({}, {__call = function(_, ...) return _local.new(...) end})