minesweeper = require("game/game")

function love.load()
	love.graphics.setBackgroundColor(35/255, 42/255, 50/255, 1)
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)
    
    math.randomseed( os.time() )
    math.random(); math.random(); math.random()

    def_font = love.graphics.newFont( "assets/fonts/MatchupPro.ttf", 30, "normal" )

    
    minesweeper.setup()
    minesweeper.new_game()
end

function love.update(dt)
    minesweeper.update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(48/255, 53/255, 57/255, 1)
    minesweeper.draw()
end

function love.keypressed(k)
	if k == 'escape' then
		print("Quitting... Goodbye!")
		love.event.quit()
    end
    if k == 'n' then
        minesweeper.new_game()
    end
    if k == 'a' then
        minesweeper.autosolve()
    end
    if k == '1' then
        minesweeper.set_diff(1)
    end
    if k == '2' then
        minesweeper.set_diff(2)
    end
    if k == '3' then
        minesweeper.set_diff(3)
    end
end

function love.mousepressed(x, y, button, istouch)
    minesweeper.handle_mouse(button, x, y)
end