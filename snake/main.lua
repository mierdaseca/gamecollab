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
    gfx.image = loadImage("snake", "images/snake.png")
    gfx.scale = 2
    gfx.tile = 16
    gfx.sprites = spriteSheet(gfx.image, gfx.tile)
    gfx.width = love.graphics.getWidth()
    gfx.height = love.graphics.getHeight()
	
	screen = {}
	
	screen.intro = loadImage("intro", "images/intro.png")
	screen.pause = loadImage("pause", "images/pause.png")
	screen.scores = loadImage("scores", "images/highscores.png")
	screen.menu = loadImage("menu", "images/menu.png")
	screen.dead = loadImage("dead", "images/dead.png")
	screen.gameover = loadImage("gameover", "images/gameover.png")

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
    
	spr.fruit = gfx.sprites[4][3]
    spr.block = gfx.sprites[4][4]	

    view = {}
    view.x = -4
    view.y = 0
    view.w = (gfx.width / gfx.tile) / gfx.scale
    view.h = (gfx.height / gfx.tile) / gfx.scale
    view.pad = 8
	
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
			lives = 3
			stateInit()
		elseif keys.down["escape"] or keys.down["q"]  then
			gameQuit()
		end
	
	-- Update Game
	elseif state == "game" then
		updateSnake(dt)
		updateEnemy(dt)
		updateView(dt)
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
		
	-- Draw Pause
	elseif state == "pause" then
		drawImage(screen.pause, 0, 0, "center")
		
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

-- ****************************************
--   Game
-- ****************************************

function updateView(dt)
    local s = snake
    local v = view
    while s.x < v.x + v.pad do v.x = v.x - 1 end
    while s.y < v.y + v.pad do v.y = v.y - 1 end
    while s.x > v.x + v.w - v.pad do v.x = v.x + 1 end
    while s.y > v.y + v.h - v.pad do v.y = v.y + 1 end
end

function gameDie()
	lives = lives - 1
	
	if lives == 0 then
		state = "gameover"
	else
		state = "dead"
	end
end

function gameQuit()
    love.event.push("q")    
end
