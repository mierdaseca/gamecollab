-- ==================================================
--
--     main.lua
--
--
--
-- ==================================================

-- Don't forget that Lua arrays begin at 1!
-- "for i=1, 10 do" is a range of 1 to 10
-- different to how arrays are iterated in C:
-- "for( i=0; i<10; i++ )" range of 0 to 9

-- game.width, game.height fields removed

require("map.lua")
require("hud.lua")
require("snake.lua")
require("fruit.lua")
require("score.lua")
require("draw.lua")

-- ****************************************
--   Main
-- ****************************************

function love.load()
    
    love.graphics.setBackgroundColor(26, 19, 0)
    
    gfx = {}
    gfx.scale = 2
    gfx.tile = 16
	gfx.image = loadImage("images/snake.png")
    gfx.sprites = spriteSheet(gfx.image, gfx.tile)
    gfx.width = love.graphics.getWidth()
    gfx.height = love.graphics.getHeight()
	
	gfx.paused = loadBumper(gfx.image, 5, 12, 3.25, 0.80)
	gfx.score = loadBumper(gfx.image, 5, 9, 2.35, 0.80)
	gfx.level = loadBumper(gfx.image, 5, 10, 2.35, 0.80)	
	gfx.lives = loadBumper(gfx.image, 8, 9, 2.00, 1.05)
	
	screen = {}
	
	screen.intro = loadImage("images/intro.png")
	screen.pause = loadImage("images/pause.png")
	screen.scores = loadImage("images/highscores.png")
	screen.menu = loadImage("images/menu.png")
	screen.dead = loadImage("images/dead.png")
	screen.gameover = loadImage("images/gameover.png")
	screen.three = loadImage("images/three.png")
	screen.two = loadImage("images/two.png")
	screen.one = loadImage("images/one.png")
	
    font = {}
    font = love.graphics.newImageFont("images/font.png", "1234567890, ")
    love.graphics.setFont(font)
	
	keys = {}
	keys.down = {} -- I didn't go with isDown, isHeld & isUp because love.keyboard already has an isDown module/field/table and it behaves differently/stupidly
	keys.held = {}
	keys.up = {}
	
	keysRegister("escape")
	keysRegister("return")
	keysRegister("q")
	keysRegister("r")

    spr = {}
    spr.snake = gfx.sprites[1][1]
    spr.snakeW= gfx.sprites[2][1]
    spr.snakeE= gfx.sprites[3][1]
    spr.snakeN= gfx.sprites[4][1]
    spr.snakeS= gfx.sprites[5][1]
	
    spr.enemy = gfx.sprites[1][2]
    spr.enemyW= gfx.sprites[2][2]
    spr.enemyE= gfx.sprites[3][2]
    spr.enemyN= gfx.sprites[4][2]
    spr.enemyS= gfx.sprites[5][2]
	
	spr.forkW = gfx.sprites[1][7]
	spr.forkE = gfx.sprites[2][7]
	spr.forkN = gfx.sprites[3][7]
	spr.forkS = gfx.sprites[4][7]
    
	spr.fruit = gfx.sprites[4][3]
    spr.block = gfx.sprites[4][4]
	
	game = {}
	
	game.lives = -1
	game.time = 0.0
	
    view = {}
	view.rate = 0.0078125
	view.time = 0.0
    view.x = 0
    view.y = 0
    view.w = 256
    view.h = 192
	
	map = map01
	
	state = "intro"
	
	stateInit()
end

function love.update(dt)
	stateUpdate(dt)
	if key == "r" then
        love.filesystem.load("main.lua")()
        love.load()
    end
	keysUpdate()
end

function love.draw()
	stateDraw()
end

-- ****************************************
--   State
-- ****************************************

function stateInit()
	-- Init Game
	if state == "game" then
		initMap()
		initScoreHandler()
		initSnake()
		initEnemy()
		initFruit()
		initHud()
	end
	
end

function stateUpdate(dt)
	-- Update Intro
	if state == "intro" then
		if keys.down["any"] then
			state = "menu"
		end
	
	-- Update Menu
	elseif state == "menu" then
		if keys.down["return"] then
			state = "game"
			game.lives = 3
			game.time = 0.00
			stateInit()
		elseif keys.down["escape"] or keys.down["q"]  then
			gameQuit()
		end
	
	-- Update Game
	elseif state == "game" then
		if game.time > 3.00 then
			updateSnake(dt)
			updateEnemy(dt)
			updateView(dt)
		else
			game.time = game.time + dt
		end
		if keys.down["escape"] then
			state = "pause"
		end
	
	-- Update Pause
	elseif state == "pause" then
		if keys.down["escape"] then
			state = "game"
		elseif keys.down["q"] then
			state = "menu"
		end
		
	-- Update Dead
	elseif state == "dead" then
		if keys.down["any"] then
			game.time = 0.0
			state = "game"
			stateInit()
		end
		
	-- Update Game Over
	elseif state == "gameover" then
		if keys.down["any"] then
			state = "scores"
		end
		
	-- Update High Scores
	elseif state == "scores" then
		if keys.down["any"] then
			state = "menu"
		end
		
	end
end

function stateDraw()
	-- Draw Intro
	if state == "intro" then
		drawImage(screen.intro, 0, 0, "center")
		
	-- Draw Menu
	elseif state == "menu" then
		drawImage(screen.menu, 0, 0, "center")
	
	-- Draw Game
	elseif state == "game" then
		drawMap()
		drawShadows()
		drawSnake(snake)
		drawSnake(enemy)
		drawFruit()
		
		if game.time < 1.00 then drawImage(screen.three, 0, 0, "center")
		elseif game.time < 2.00 then drawImage(screen.two, 0, 0, "center")
		elseif game.time < 3.00 then drawImage(screen.one, 0, 0, "center") else
			
			drawBumper(gfx.lives, 24, 16, "left")
			drawBumper(gfx.level, gfx.width / 2, 16, "middle")
			drawBumper(gfx.score, gfx.width - 24, 16, "right")
			
		end
		
	-- Draw Pause
	elseif state == "pause" then
		-- drawImage(screen.pause, 0, 0, "center")
		drawMap()
		drawShadows()
		drawSnake(snake)
		drawSnake(enemy)
		drawFruit()
		
		drawBumper(gfx.paused, gfx.width/2, gfx.height/2, "center")
			
	-- Draw Dead
	elseif state == "dead" then
		drawImage(screen.dead, 0, 0, "center")
		
	-- Draw Game Over
	elseif state == "gameover" then
		drawImage(screen.gameover, 0, 0, "center")
		
	-- Draw High Scores
	elseif state == "scores" then
		drawImage(screen.scores, 0, 0, "center")

	end
end

-- ****************************************
--   Game
-- ****************************************

function updateView(dt)
    local s = snake
    local v = view
	if v.time > view.rate then
		if s.x * gfx.tile * gfx.scale < v.x + v.w then v.x = v.x - 1 v.time = 0.0 end
		if s.y * gfx.tile * gfx.scale < v.y + v.h then v.y = v.y - 1 v.time = 0.0 end
		if s.x * gfx.tile * gfx.scale > v.x + gfx.width - v.w then v.x = v.x + 1 v.time = 0.0 end
		if s.y * gfx.tile * gfx.scale > v.y + gfx.height - v.h then v.y = v.y + 1 v.time = 0.0 end
	else
		v.time = v.time + dt
	end
end

function gameDie()
	game.lives = game.lives - 1
	
	if game.lives == 0 then
		state = "gameover"
	else
		state = "dead"
	end
end

function gameQuit()
    love.event.push("q")    
end

-- ****************************************
--   Keys/Input
--
--     Index with "any" to see if a key
--     is being pressed/held. Useful for
--     intro/score/game over screens?
--
-- ****************************************

function love.keypressed(key)
	keys.down[key] = true
	keys.held[key] = true
	keys.down["any"] = true
	keys.held["any"] = true
end

function love.keyreleased(key)
	keys.up[key] = true
	keys.held[key] = false
	keys.up["any"] = true
	keys.held["any"] = false
end

function keysRegister(key)
	keys.down[key] = false
	keys.held[key] = false
	keys.up[key] = false
end

function keysUpdate(dt)
	for k, v in pairs(keys.down) do keys.down[k] = false end
	for k, v in pairs(keys.up) do keys.up[k] = false end
	keys.down["any"] = false
	keys.up["any"] = false
end
