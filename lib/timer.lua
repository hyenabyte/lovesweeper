-- A timer

local TIMER = 
{
    time_s = 0,
    time_c = 0,

    running = false,
}

function TIMER:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function TIMER:start()
    self.running = true
    self.time_s = love.timer.getTime()
end

function TIMER:stop()
    self.running = false
    self.time_c = self.time_c + love.timer.getTime() - self.time_s
end

function TIMER:reset()
    self.time_s = love.timer.getTime()
    self.time_c = 0
end

function TIMER:get_time()
    if self.running then
        return (love.timer.getTime() - self.time_s) +  self.time_c
    else 
        return self.time_c
    end
end

function TIMER:get_time_string()
    t = self:get_time()

    seconds = t % 60
    minutes = math.floor(t / 60)

    return string.format( "%02d:%04.1f", minutes, seconds )
end


return TIMER