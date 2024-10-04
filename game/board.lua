-- Game Board

deque = require("lib/deque")
events = require("lib/events")

local BOARD =
{

    width = 16,
    height = 16,
    n_mines = 40,

    offset_x = 0,
    offset_y = 0,

    tile_size = 32,


    mines = {},
    numbers = {},
    mines_laid = false,

    tiles = {},

    t_blank = 0,
    t_mine = 1,
    t_covered = 2,
    t_flag = 3,

    game_lost = false,
    game_won = false,

    events = {},
    game_won_event = {},

    lost_tile_x = -1,
    lost_tile_y = -1

}

function BOARD:new(o)

    o = o or {}
	setmetatable(o, self)
    self.__index = self

    self.events = events:new()
    self.events:setup(true)

    self.events:add("game_start")
    self.events:add("game_won")
    self.events:add("game_lost")

    return o
end

function BOARD:set_size(w,h)
    self.width = w or self.width
    self.height = h or self.heigh
end

function BOARD:new_2D_Array(w,h,f)

    width = w or self.width
    height = h or self.height
    fill = f or self.t_blank

    a = {}

    for x = 1, width do
        a[x] = {}
        for y = 1, height do
            a[x][y] = fill
        end
    end

    return a

end

-- check if a mine can be placed at a given spot
-- x and y is coordinate being checked
-- s_x and s_y is a custom spot that is invalid (used for the first clicked spot in the game)
function BOARD:is_valid_mine(x,y,s_x,s_y)

    if x <= 0 or x > self.width or y <= 0 or y > self.height then
        return false
    elseif x == s_x and y == s_y then
        return false
    elseif self.mines[x][y] == self.t_blank then
        return true
    else
        return false
    end

end

function BOARD:lay_mines(x,y)

    -- mines are first placed after the first tile is clicked
    -- since the first tile always should be blank

    -- x,y is the tile clicked by the player
    -- and is reserved as a blank space

    self.mines = self:new_2D_Array(self.width, self.height, self.t_blank)

    for i = 1, self.n_mines do
        m_x = -1
        m_y = -1
        while not self:is_valid_mine(m_x,m_y,x,y) do
            m_x = love.math.random( 1, self.width )
            m_y = love.math.random( 1, self.height )
        end
        self.mines[m_x][m_y] = self.t_mine
    end

    for i = 1, self.width do
        for j = 1, self.height do
            self.numbers[i][j] = self:get_neighbors_count(i,j)
        end
    end
    self.mines_laid = true
    print("Mines generated")
    self.events:invoke("game_start")

end

function BOARD:get_neighbor_array(x,y)
    -- gets all neighbors with a bunch of if statements
    a = {}

    if x > 1 then table.insert(a, {x-1, y}) end                                 -- left
    if y > 1 then table.insert(a, {x, y-1}) end                                 -- top
    if x > 1 and y > 1 then table.insert(a, {x-1, y-1}) end                     -- top left
    if y > 1 and x < self.width then table.insert(a, {x+1, y-1}) end            -- top right
    if x < self.width then table.insert(a, {x+1, y}) end                        -- right
    if x < self.width and y < self.height then table.insert(a, {x+1, y+1}) end  -- bottom right
    if x > 1 and y < self.height then table.insert(a, {x-1, y+1}) end           -- bottom left
    if y < self.height then table.insert(a, {x, y+1}) end                       -- bottom

    return a

end

function BOARD:get_neighbors_count(x,y)
    -- gets count of neighbors
    -- by counting neighbor array
    counter = 0

    neighbors = self:get_neighbor_array(x,y)

    for k,item in pairs(neighbors) do
        if self.mines[item[1]][item[2]] == self.t_mine then
            counter = counter + 1
        end
    end

    return counter

end

-- Mouse click handler
function BOARD:mouse_click(btn, x, y)

    -- dont do anything if game is over
    if self.game_lost or self.game_won then return end

    coords = self:coords_to_grid(x,y)

    if coords[1] < 1 or
       coords[1] > self.width or
       coords[2] < 1 or
       coords[2] > self.height then
        return
    end

    if btn == 1 then
        -- uncover tile on left click
        self:click_tile(coords[1], coords[2])
    elseif btn == 2 then
        -- place flag on right click
        self:set_flag(coords[1], coords[2])
    end

end

-- convert canvas coords to grid coords
function BOARD:coords_to_grid(x,y)

    if x < self.offset_x or
       y < self.offset_y or
       x > self.offset_x + self.width * self.tile_size or
       y > self.offset_y + self.width * self.tile_size then
        return {-1,-1}
    end

    g_x = math.ceil((x - self.offset_x) / self.tile_size)
    g_y = math.ceil((y - self.offset_y) / self.tile_size)

    return {g_x, g_y}

end

-- uncover tile
function BOARD:click_tile(x,y)

    -- lay mines on first click
    if not self.mines_laid then
        self:lay_mines(x,y)
    end

    -- check if tile is uncovered
    if self.tiles[x][y] == self.t_covered then
        -- if clicked tile is mine, explode mine
        if self.mines[x][y] == self.t_mine then
            self.lost_tile_x = x
            self.lost_tile_y = y
            self:explode()
            return
        end

        -- uncover tile
        self:uncover(x,y)
    end

    -- check if game is won after clicked tile
    if self:check_won() then
        self.game_won = true
        self.events:invoke("game_won")
    end

end

-- set flag on tile
function BOARD:set_flag(x,y)

    if self.tiles[x][y] == self.t_covered then
        self.tiles[x][y] = self.t_flag
    elseif self.tiles[x][y] == self.t_flag then
        self.tiles[x][y] = self.t_covered
    end

end

-- check if game is won
function BOARD:check_won()

    for x=1, self.width do
        for y=1, self.height do

            -- check if any covered or flagged tiles has no mine under
            if self.tiles[x][y] == self.t_covered or self.tiles[x][y] == self.t_flag then
                if self.mines[x][y] ~= self.t_mine then
                    -- if there is no mine under, game isn't won yet
                    return false
                end
            end

        end
    end
    -- if alll tiles are either uncovered or has a mine under, game is won
    return true
end

-- check a tile
function BOARD:uncover(x,y,queue)

    -- new queue of tiles
    q = deque.new()

    -- add initial tile to queue
    if self.tiles[x][y] == self.t_covered then
        q:push_left({x,y})
    end

    while not q:is_empty() do

        -- check first tile in queue
        tile = q:pop_right()

        t_x = tile[1]
        t_y = tile[2]

        if self.tiles[t_x][t_y] == self.t_covered then

            -- set current to blank
            self.tiles[t_x][t_y] = self.t_blank

            -- if current tile is a zero (no number) check it's neighbors aswell
            if self.numbers[t_x][t_y] == 0 then

                neighbors = self:get_neighbor_array(tile[1], tile[2])

                -- add covered- non-mine-neighbors to list and continue loop
                for k,item in pairs(neighbors) do
                    if self.tiles[item[1]][item[2]] == self.t_covered and
                       self.mines[item[1]][item[2]] == self.t_blank then
                        q:push_left({item[1], item[2]})
                    end
                end

            end
        end

    end
end

function BOARD:explode()
    self.game_lost = true
    self.events:invoke("game_lost")
end

function BOARD:new_game(w,h,n)

    self.n_mines = n or self.n_mines
    self.width = w or self.width
    self.height = h or self.height

    self.mines = self:new_2D_Array(self.width, self.height, self.t_blank)
    self.numbers = self:new_2D_Array(self.width, self.height, 0)
    self.tiles = self:new_2D_Array(self.width, self.height, self.t_covered)
    self.mines_laid = false
    self.game_lost = false
    self.game_won = false

end

function BOARD:hook_callback(hook, callback)
    self.events:hook(hook, callback)
end

return BOARD
