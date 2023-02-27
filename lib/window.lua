local b = require('lib.button')
local gui = require('lib.gui')

local WINDOW = 
{   
    window_x = 10,
    window_y = 10,
    window_w = 128,
    window_h = 128,

    padding = 10,

    bg_col = {20/255,20/255,20/255,1},
    header_col = {100/255,100/255,100/255,1},
    border_col = {70/255,70/255,70/255,1},
    label_col = {200/255,200/255,200/255,1},

    canvas = nil,
    canvas_w = 0,
    canvas_h = 0,

    camera = nil,

    draggable = true,
    scaleable = false,
    minimizeable = false,

    grabbed = false,

    rel_x = 0,
    rel_y = 0
}

function WINDOW:new(o)
	o = o or {}
	setmetatable(o, self)
    self.__index = self
	return o
end

function WINDOW:init()
    self.canvas_w = self.window_w - (self.padding * 2)
    self.canvas_h = self.window_h - (self.padding*2) - self.header_h


    self.canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h);
end

local function updateButtons(button_array)
    for key,value in pairs(button_array) do
        button_array[key]:update()
    end
end

function WINDOW:updateContent() end

function WINDOW:update()
    local m_x, m_y = love.mouse.getPosition()

    updateButtons(self.header_buttons)

    if m_x > self.window_x and m_x < self.window_x + self.window_w and
    m_y > self.window_y and m_y < self.window_y + self.header_h and not self.grabbed then
        if love.mouse.isDown(1) and self.draggable and not self.grabbed then
            self.grabbed = true
            self.rel_x = m_x - self.window_x
            self.rel_y = m_y - self.window_y
        end
    end

    if self.grabbed then
        self.window_x = m_x - self.rel_x
        self.window_y = m_y - self.rel_y

        if not love.mouse.isDown(1) then
            self.grabbed = false
        end
    end
    self:updateContent()
end

local function drawButtons(button_array)
    for key,value in pairs(button_array) do
        button_array[key]:draw()
    end
end

function WINDOW:content() end

function WINDOW:draw()
    --draw window
    love.graphics.setColor(self.bg_col)
    love.graphics.rectangle("fill", self.window_x, self.window_y, self.window_w, self.window_h)
    love.graphics.setColor(self.border_col)
    love.graphics.rectangle("line", self.window_x, self.window_y, self.window_w, self.window_h)
    local inner_x = self.window_x + self.padding
    local inner_y = self.window_y + self.padding
    if self.draggable then
        inner_y = inner_y + self.header_h
        love.graphics.setColor(self.header_col)
        love.graphics.rectangle("fill", self.window_x, self.window_y, self.window_w, self.header_h)
        love.graphics.setColor(self.label_col)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setCanvas(self.header_canvas)
        love.graphics.clear()
        love.graphics.draw(self.label,0,0)
        drawButtons(self.header_buttons)
        love.graphics.setCanvas()
        love.graphics.draw(self.header_canvas,self.window_x + self.padding,self.window_y + self.padding)
    end
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)
    self:content()
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, inner_x, inner_y)
end

function WINDOW:mouseOnCanvas()
    local inner_x = self.window_x + self.padding
    local inner_y = self.window_y + self.padding + self.header_h
    local m_x, m_y = love.mouse.getPosition()
    return m_x > inner_x and m_x < inner_x + self.canvas_w and
        m_y > inner_y and m_y < inner_y + self.canvas_h
end

function WINDOW:mouseLocalPosition()
    local inner_x = self.window_x + self.padding
    local inner_y = self.window_y + self.padding + self.header_h
    local m_x, m_y = love.mouse.getPosition()
    l_x = m_x - inner_x
    l_y = m_y - inner_y

    return l_x, l_y
end

return WINDOW