-- Game header

--
local ts = require("game/tileset")
local g = require("lib/gui")
local btn = require("lib/button")


local HEADER =
{
    canvas = {},
    time = "00:00.0",
    timer_margin = 3,
    width = 0,
    height = 64,

    gui = nil,
    btn_w = 70,
    easy_button = nil,
    medium_button = nil,
    hard_button = nil,
}

function HEADER:new(o)
	o = o or {}
	setmetatable(o, self)
    self.__index = self

    self.gui = g:new()
    self.easy_button = btn:new()
    self.medium_button = btn:new()
    self.hard_button = btn:new()
	return o
end

function HEADER:setup(w, h)
    self.width = w or self.width
    self.height = h or self.height

    btn_h_x = self.width - self.btn_w
    btn_m_x = self.width - (self.btn_w * 2)
    btn_e_x = self.width - (self.btn_w * 3)

    self.easy_button:setup(btn_e_x, 0, self.btn_w, self.height -8, "Easy" )
    self.medium_button:setup(btn_m_x, 0, self.btn_w, self.height -8, "Medi" )
    self.hard_button:setup(btn_h_x, 0, self.btn_w, self.height -8, "Hard" )

    self.canvas = love.graphics.newCanvas(self.width, self.height)
end

function HEADER:update(dt)
    --self.easy_button:update()
    --self.medium_button:update()
    --self.hard_button:update()
end

function HEADER:set_time(t)
    self.time = t
end

function HEADER:draw_timer(x,y)

    love.graphics.setColor(1,0,0,1)
    timer_text = love.graphics.newText(def_font, self.time)
    --print(timer_text:getWidth())
    love.graphics.draw(timer_text, x + self.timer_margin, y + self.timer_margin)
    love.graphics.setColor(1,1,1,1)

end

function HEADER:draw(x,y)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setColor(48/255,53/255,57/255,1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(1,1,1,1)
    self.gui:draw_border(0, 0, 90, self.height - 8)
    self.gui:draw_rectangle(90, 0, self.width - 90, self.height - 8)
    self:draw_timer(10,2)

    --self.easy_button:draw()
    --self.medium_button:draw()
    --elf.hard_button:draw()

    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, x, y)
end

return HEADER
