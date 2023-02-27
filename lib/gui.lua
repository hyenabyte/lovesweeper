local GUI ={}

function GUI:new(o)
	o = o or {}
	setmetatable(o, self)
    self.__index = self
	return o
end

function GUI:draw_border(x, y, w, h)
    love.graphics.setColor(138/255, 141/255, 146/255, 1)
    love.graphics.setLineWidth(8)

    love.graphics.rectangle("line", x + 4, y + 4, w - 8, h - 8)

    love.graphics.setLineWidth(2)

    love.graphics.setColor(173/255, 179/255, 185/255, 1)
    love.graphics.line(x + 1, y + h - 2, x + 1, y + 1, x + w - 2, y + 1)
    love.graphics.line(x + 8, y + h - 7, x + w - 7, y + h - 7, x + w - 7, y + 8)

    love.graphics.setColor(86/255, 97/255, 107/255, 1)
    love.graphics.line(x + 2, y + h - 1, x + w - 1, y + h - 1, x + w - 1, y + 2)
    love.graphics.line(x + 7, y + h - 9, x + 7, y + 7, x + w - 9, y + 7)

    love.graphics.setColor(1, 1, 1, 1)
end

function GUI:draw_rectangle(x,y,w,h)
    love.graphics.setColor(138/255, 141/255, 146/255, 1)

    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(173/255, 179/255, 185/255, 1)
    love.graphics.line(x + 1, y + h - 2, x + 1, y + 1, x + w - 2, y + 1)
    --love.graphics.line(x + 8, y + h - 7, x + w - 7, y + h - 7, x + w - 7, y + 8)

    love.graphics.setColor(86/255, 97/255, 107/255, 1)
    love.graphics.line(x + 2, y + h - 1, x + w - 1, y + h - 1, x + w - 1, y + 2)
    --love.graphics.line(x + 7, y + h - 9, x + 7, y + 7, x + w - 9, y + 7)
    love.graphics.setColor(1, 1, 1, 1)
end

return GUI