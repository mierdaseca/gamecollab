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
--   Love
-- ****************************************

function love.load()
    
    love.graphics.setBackgroundColor(26, 19, 0)
    
    gfx = {}
    gfx.image = love.graphics.newImage("snake.png")
    gfx.image:setFilter("nearest", "nearest")
    gfx.scale = 2
    gfx.tile = 16
    gfx.sprites = spriteSheet(gfx.image, gfx.tile)
    gfx.width = love.graphics.getWidth()
    gfx.height = love.graphics.getHeight()
    
    font = {}
    font = love.graphics.newImageFont("font.png", "1234567890, ")
    love.graphics.setFont(font)

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

	initMap()
    initScoreHandler()
    initSnake()
	initEnemy()
    initFruit()
    initHud()
end

function love.update(dt)
    updateSnake(dt)
	updateEnemy(dt)
    updateView(dt)
end

function love.draw()
	drawMap()
	drawShadows()
    drawSnake(snake)
    drawSnake(enemy)
    drawFruit()
    -- drawHud()
end

function love.keypressed(key)
    if key == "escape" or key == "q" then
        gameQuit()
    elseif key == "r" then
        love.filesystem.load("main.lua")()
        love.load()
    end
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
