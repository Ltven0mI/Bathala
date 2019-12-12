local Gamestate = require "hump.gamestate"
local Camera = require "hump.camera"

local Sfx = require "classes.sfx"

local Console = require "core.console"

local game_gamestate = require "gamestates.game"
local mapeditor_gamestate = require "gamestates.mapeditor"

local menu = {}

menu.uiCamera = nil
menu.selectSfx = nil
menu.titleScreenBg = nil
menu.startButton = nil
menu.quitButton = nil
menu.editorButton = nil


function menu:enter()
    local screenW, screenH = love.graphics.getDimensions()
    local halfW, halfH = math.floor(screenW / 2), math.floor(screenH / 2)
    self.uiCamera = Camera(halfW / 4, halfH / 4, 4)

    self.selectSfx = Sfx("assets/sound/ui_select.wav")

    self.titleScreenBg = love.graphics.newImage("assets/images/ui/titlescreen/titlescreen_bg.png")
    self.startButton = {
        x=91,
        y=73,
        w=37,
        h=13,
        isHovered=false,
        img = love.graphics.newImage("assets/images/ui/titlescreen/start_button.png")
    }
    self.quitButton = {
        x=91,
        y=92,
        w=37,
        h=13,
        isHovered=false,
        img = love.graphics.newImage("assets/images/ui/titlescreen/quit_button.png")
    }
    self.editorButton = {
        x=91,
        y=111,
        w=37,
        h=13,
        isHovered=false,
        img = love.graphics.newImage("assets/images/ui/titlescreen/start_button.png")
    }
end

function menu:leave()
    self.uiCamera = nil
    self.selectSfx = nil
    self.titleScreenBg = nil
    self.startButton = nil
    self.quitButton = nil
    self.editorButton = nil
end

function menu:update(dt)
    Console.update(dt)
end

function menu:draw()
    self.uiCamera:attach()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.titleScreenBg, 0, 0)

    self:drawButton(self.startButton)
    self:drawButton(self.quitButton)
    self:drawButton(self.editorButton)

    self.uiCamera:detach()

    Console.draw()
end

function menu:mousepressed(x, y, btn)
    if self.startButton.isHovered then
        Gamestate.switch(game_gamestate)
    elseif self.quitButton.isHovered then
        love.event.quit()
    elseif self.editorButton.isHovered then
        Gamestate.switch(mapeditor_gamestate)
    end
end

function menu:mousemoved(x, y)
    local worldX, worldY = self.uiCamera:worldCoords(x, y)
    self:buttonMouseMoved(self.startButton, worldX, worldY)
    self:buttonMouseMoved(self.quitButton, worldX, worldY)
    self:buttonMouseMoved(self.editorButton, worldX, worldY)
end

function menu:buttonMouseMoved(button, mx, my)
    local lastIsHovered = button.isHovered
    button.isHovered = (
        mx >= button.x and mx < button.x + button.w and
        my >= button.y and my < button.y + button.h
    )
    if button.isHovered and not lastIsHovered then
        self.selectSfx:play()
    end
end

function menu:drawButton(button)
    love.graphics.setColor(1, 1, 1, 1)
    local offsetY = button.isHovered and -1 or 0
    love.graphics.draw(button.img, button.x, button.y + offsetY)
end

function menu:keypressed(key, isRepeat)
    Console.keypressed(key, isRepeat)
end

function menu:textinput(text)
    Console.textinput(text)
end

return menu