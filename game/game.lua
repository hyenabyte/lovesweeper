-- Game
local b = require("game/board")
local ts = require("game/tileset")
local diff = require("game/difficulty")
local t = require("lib/timer")
local h = require("game/header")
local g = require("lib/gui")
local btn = require("lib/button")

local game = {}

local canvas = nil
local board = b:new()
local timer = t:new()
local header = h:new()

local gui = g:new()

local difficulty = diff.medium

local width = difficulty[1]
local height = difficulty[2]

local t_size = 32

local w_width = 0
local w_height = 0
local w_top_margin = 48
local w_bottom_margin = 8
local w_right_margin = 8
local w_left_margin = 8

local w_fullscreen = false
local w_fullscreen_type = "desktop"
local w_vsync = 1
local w_msaa = 0
local w_stencil = true
local w_depth = 0
local w_resizeable = false
local w_borderless = false
local w_centered = true
local w_display = 1
local w_minwidth = 1
local w_minheight = 1
local w_highdpi = false
local w_x = nil
local w_y = nil
local w_usedpiscale = true

local tileset = ts:new()
local tileset_path = "assets/sprites/tileset.png"

local show_overlay = false
local o_w = 200
local o_h = 140

local o_text = "overlay text"
local o_button = btn:new()
local o_btn_label = "New Game"
local o_btn_w = 140
local o_btn_h = 40

local o_canvas = nil

-- called in setup
function game.setup()
    board:set_size(width, sh)
    tileset:SetTileset(tileset_path, board.tile_size)

    game.recalculate_window_size()

    canvas = love.graphics.newCanvas(w_width, w_height)

    board:hook_callback("game_start", game.start_callback)
    board:hook_callback("game_won", game.won_callback)
    board:hook_callback("game_lost", game.lost_callback)

    header:setup(w_width, w_top_margin)

    o_canvas = love.graphics.newCanvas(o_w, o_h)
    o_button.events:hook('on_click', game.new_game)

    --header.easy_button.events:hook('on_click', game.set_easy)
    --header.medium_button.events:hook('on_click', game.set_medi)
    --header.hard_button.events:hook('on_click', game.set_hard)
end

-- Mouse handeling
function game.handle_mouse(btn,x,y)
    board:mouse_click(btn, x - w_left_margin, y - w_top_margin)
end

-- game loop
function game.update(dt)
    -- pass time to header
    header:update()
    header:set_time(timer:get_time_string())

    o_button:update()
end

-- Draw the game board
function game.draw()
    love.graphics.setCanvas(canvas) -- draw in window canvas
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)

    mouse_x = love.mouse.getX() - w_left_margin
    mouse_y = love.mouse.getY() - w_top_margin

    for x=1, width do
        for y=1, height do

            -- Convert index to canvas coordinates
            coord_x = (x - 1) * board.tile_size
            coord_y = (y - 1) * board.tile_size

            -- Get hovered tile
            m_hover = mouse_x > coord_x and
                      mouse_x < coord_x + board.tile_size and
                      mouse_y > coord_y and
                      mouse_y < coord_y + board.tile_size and
                      not board.game_lost and
                      not board.game_won

            -- Draw covered tiles
            if board.tiles[x][y] == board.t_covered then

                if m_hover then
                    -- If mouse hovering over
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 1)
                else
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 0)
                end

                -- Draw mines on top when lost
                if board.game_lost then
                    if board.lost_tile_x == x and board.lost_tile_y == y then
                        tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 1)
                    end
                    if board.mines[x][y] == board.t_mine then
                        tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 5)
                    end
                end

            elseif board.tiles[x][y] == board.t_flag then
                -- Draw flags
                if m_hover then
                    -- Hovering
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 1)
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 3)
                else
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 0)

                    if board.game_lost then
                        if board.mines[x][y] == board.t_mine then
                            tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 5)
                            tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 2)
                        else
                            tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 14)
                        end
                    else
                        tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 2)
                    end

                end

            elseif board.tiles[x][y] == board.t_blank then
                -- blank tiles
                tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, 4)

                -- numbers on blank tiles
                if board.numbers[x][y] > 0 then
                    number = board.numbers[x][y] + 5
                    tileset:DrawTile((x - 1) * board.tile_size,(y - 1) * board.tile_size, number)
                end
            end
        end
    end
    love.graphics.setCanvas()

    header:draw(0,0) -- header bar
    gui:draw_border(0, w_top_margin - 8, w_width, w_height - w_top_margin + 8) -- border around game board

    love.graphics.draw(canvas, w_left_margin, w_top_margin) -- draw the canvas

    -- super janky overlay
    o_button.active = show_overlay
    if show_overlay then
        love.graphics.setColor(0,0,0,0.4)
        love.graphics.rectangle("fill", w_left_margin, w_top_margin, w_width - 16, w_height - w_top_margin - 8)


        love.graphics.setCanvas(o_canvas)
        gui:draw_rectangle(0, 0, o_w, o_h)

        love.graphics.setColor(0,0,0,1)
        text_obj = love.graphics.newText(def_font, o_text)

        text_w = text_obj:getWidth()
        text_offset = o_w / 2 - text_w / 2


        love.graphics.draw(text_obj, text_offset, 20)
        love.graphics.setColor(1,1,1,1)

        love.graphics.setCanvas()



        o_x = w_left_margin + (w_width - 16) / 2 - (o_w / 2)
        o_y = w_top_margin + (w_height - w_top_margin - 8) / 2 - (o_h / 2)
        love.graphics.draw(o_canvas, o_x, o_y)

        btn_x = (o_w / 2 - o_btn_w / 2) + o_x
        btn_y = (o_h - (o_btn_h + 20)) + o_y


        o_button:setup(btn_x, btn_y, o_btn_w, o_btn_h, o_btn_label)
        o_button:draw()
    end

    love.graphics.setColor(1,1,1,1)
end

-- called when game begins after first tile is clicked
function game.start_callback()
    print("Game begun")
    timer:start()
end

-- called when the game is won ie. no more tiles left to uncover
function game.won_callback()
    print("Game over: game won")
    show_overlay = true
    o_text = "You win!"
    timer:stop()
end

-- called when game is lost
function game.lost_callback()
    print("Game over: game lost")
    show_overlay = true
    o_text = "You lose!"
    timer:stop()
end

-- change window size to match the board, header and thier borders
function game.recalculate_window_size()
    -- get board width and height
    width = difficulty[1]
    height = difficulty[2]

    -- calculate window size
    w_width = (width * t_size) + w_right_margin + w_left_margin
    w_height = (height * t_size) + w_top_margin + w_bottom_margin

    -- reset canvas
    canvas = love.graphics.newCanvas(w_width, w_height)
    header:setup(w_width, w_top_margin)

    -- not sure why this is here
    local flags = {
        w_fullscreen,
        w_fullscreen_type,
        w_vsync,
        w_msaa,
        w_stencil,
        w_depth,
        w_resizeable,
        w_borderless,
        w_centered,
        w_display,
        w_minwidth,
        w_minheight,
        w_highdpi,
        w_x,
        w_y,
        w_usedpiscale
    }

    -- set window size
    love.window.setMode(w_width, w_height)
end

-- simple autosolve
function game.autosolve()
    print("Autosolved")
    for x=1, width do
        for y=1, height do
            if board.game_won then return end
            if board.tiles[x][y] == board.t_covered then
                if not board.mines_laid then board:lay_mines(x,y) end
                if board.mines[x][y] == board.t_blank then
                    board:click_tile(x,y)
                end
            end
        end
    end
end

function game.set_easy()
    game.set_diff(1)
end

function game.set_medi()
    game.set_diff(2)
end

function game.set_hard()
    game.set_diff(3)
end

function game.set_diff(d)
    if d == 1 then
        print("Difficulty set to easy")
        difficulty = diff.easy
    elseif d == 2 then
        print("Difficulty set to medium")
        difficulty = diff.medium
    elseif d == 3 then
        print("Difficulty set to hard")
        difficulty = diff.hard
    end
    game.recalculate_window_size()
    game.new_game()
end

function game.new_game()
    show_overlay = false
    timer:reset()
    timer:stop()
    board:new_game(width, height, difficulty[3])
end

return game
