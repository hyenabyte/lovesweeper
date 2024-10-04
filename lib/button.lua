local ev = require('lib.events')
local gui = require('lib.gui')

local BUTTON =
{
	active = true,
	pos_x = 0,
	pos_y = 0,
    size_w = 0,
	size_h = 0,
	hovering = false,
    clicked = false,
    label = "New Button",
    events = {},
    gui = {},
    label_text = nil,
}

function BUTTON:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.events = ev:new()
	self.events:setup()
	self.events:add('on_click')
    self.events:add('on_hover')

    self.gui = gui:new()
	return o
end

function BUTTON:setup(x,y,w,h,label)
	self.pos_x = x
	self.pos_y = y
	self.size_w = w
    self.size_h = h

    self.label = label or self.label
    self.label_text = love.graphics.newText(def_font, self.label)
end

function BUTTON:update()
	if not self.active then return end
	local m_x, m_y = love.mouse.getPosition()

	if m_x > self.pos_x and m_x < self.pos_x + self.size_w and
	m_y > self.pos_y and m_y < self.pos_y + self.size_h then
		if love.mouse.isDown(1) and not self.clicked then
			-- on click
			self.events:invoke('on_click')
			self.clicked = true
			self.hovering = false
		else
			-- on hover
			self.events:invoke('on_hover')
			self.hovering = true
			self.clicked = false
		end
	else
		self.hovering = false
		self.clicked = false
	end

	--self:updateContent()
end

function BUTTON:content()

    self.gui:draw_rectangle(self.pos_x, self.pos_y, self.size_w, self.size_h)

    love.graphics.setColor(0,0,0,0)
	if self.hovering then love.graphics.setColor(0,0,0,0.2) end
	if self.clicked then love.graphics.setColor(0,0,0,0.4) end
    love.graphics.rectangle("fill", self.pos_x, self.pos_y, self.size_w, self.size_h)

    love.graphics.setColor(0,0,0,1)


    t_h = self.label_text:getHeight()
    t_w = self.label_text:getWidth()

    label_offset_x = self.size_w / 2 - t_w / 2
    label_offset_y = self.size_h / 2 - t_h / 2

    love.graphics.draw(self.label_text, self.pos_x + label_offset_x, self.pos_y + label_offset_y)

end

function BUTTON:draw()
	if not self.active then return end
	self:content()
	love.graphics.setColor(1,1,1,1)
end

return BUTTON
