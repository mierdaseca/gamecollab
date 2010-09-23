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

-- ****************************************
--   Main
-- ****************************************

function love.load()
    
    love.graphics.setBackgroundColor(26, 19, 0)
    
    gfx = {}
    gfx.image = love.graphics.newImage("images/snake.png")
    gfx.image:setFilter("nearest", "nearest")
    gfx.scale = 2
    gfx.tile = 16
    gfx.sprites = spriteSheet(gfx.image, gfx.tile)
    gfx.width = love.graphics.getWidth()
    gfx.height = love.graphics.getHeight()
	
	screen = {}
	
	screen.intro = love.graphics.newImage("images/intro.png")
	screen.intro:setFilter("nearest", "nearest")
	screen.pause = love.graphics.newImage("images/pause.png")
	screen.pause:setFilter("nearest", "nearest")
	screen.scores = love.graphics.newImage("images/highscores.png")
	screen.scores:setFilter("nearest", "nearest")
	screen.menu = love.graphics.newImage("images/menu.png")
	screen.menu:setFilter("nearest", "nearest")
	screen.gameover = love.graphics.newImage("images/gameover.png")
	screen.gameover:setFilter("nearest", "nearest")
    
    font = {}
    font = love.graphics.newImageFont("images/font.png", "1234567890, ")
    love.graphics.setFont(font)
	
	keys = {}
	keys.down = {} -- I didn't go with isDown, isHeld, isUp because love.keyboard already has an isDown module/field/table and it behaves differently/stupidly
	keys.held = {}
	keys.up = {}
	
	keysAdd("escape")
	keysAdd("return")
	keysAdd("q")
	keysAdd("r")

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
	
	state = "game"
	
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
	-- Update Game
	if state == "game" then
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
		end
	end
	
end

function stateDraw()
	-- Draw Game
	if state == "game" then
		drawMap()
		drawShadows()
		drawSnake(snake)
		drawSnake(enemy)
		drawFruit()
		
	-- Draw Pause
	elseif state == "pause" then
		drawImage(screen.pause, 0, 0, "center")
	end
	
end

-- ****************************************
--   Keys/Input
-- ****************************************

function love.keypressed(key)
	keys.down[key] = true
	keys.held[key] = true
end

function love.keyreleased(key)
	keys.held[key] = false
	keys.up[key] = true
end

function keysAdd(key)
	keys.down[key] = false
	keys.held[key] = false
	keys.up[key] = false
end

function keysUpdate(dt)
	for k, v in pairs(keys.down) do keys.down[k] = false end
	for k, v in pairs(keys.up) do keys.up[k] = false end
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

function gameOver()
end

function gameQuit()
    love.event.push("q")    
end


-- ****************************************
--  Helpers
-- ****************************************

function drawTile(sprite,x,y)
    drawSprite(sprite, (x-1)*gfx.tile, (y-1)*gfx.tile)
end

function drawSprite(sprite,x,y)
    x = x - view.x * gfx.tile
    y = y - view.y * gfx.tile
    love.graphics.drawq(sprite[1], sprite[2], x*gfx.scale, y*gfx.scale, 0.0, gfx.scale, gfx.scale)
end

function spriteSheet(img,tile)
    local i, j
    local t = {}
    local w, h = img:getWidth(), img:getHeight()
    local x, y = (w/tile), (h/tile)    
    
    for i=1, x do
        t[i] = {}
        for j=1, y do
            t[i][j] = { img, love.graphics.newQuad((i-1)*tile, (j-1)*tile, tile, tile, w, h) }
        end
    end

    return t
end

function drawImage(img,x,y,str)
	if str == "center" then
		x = gfx.width / 2
		y = gfx.height / 2
		x = x - (img:getWidth() / 2)
		y = y - (img:getHeight() / 2)
	end
	
	love.graphics.draw(img, x, y)
end
