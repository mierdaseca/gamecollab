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

require("map01.lua")
require("map02.lua")

-- ****************************************
--   Love
-- ****************************************

function love.load()
    
    --require("proAudioRt")
    --proAudio.create(16,44100,1024)
    --sample = proAudio.sampleFromFile("snake/snake_battle.mp3")
    --if sample then bgm = proAudio.soundLoop(sample) end
    
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

	initMap(map02) -- Important
	
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
--   Hud
-- ****************************************

function initHud()
    local img = gfx.image
    local t = gfx.tile

    hud = {}
    hud.spr = {}
    
    hud.spr.title = love.graphics.newQuad(5*t, 7*t, 80, 32, img:getWidth(), img:getHeight())
    hud.spr.score = love.graphics.newQuad(5*t, 9*t, 48, 16, img:getWidth(), img:getHeight())
    hud.spr.lives = love.graphics.newQuad(8*t, 9*t, 32, 16, img:getWidth(), img:getHeight())
    hud.spr.level = love.graphics.newQuad(5*t,10*t, 48, 16, img:getWidth(), img:getHeight())
end

function drawHud()
    love.graphics.drawq(gfx.image, hud.spr.title, gfx.x + 8, 24, 0.0, gfx.scale, gfx.scale)
    love.graphics.drawq(gfx.image, hud.spr.score, gfx.x + 672, 16, 0.0, gfx.scale, gfx.scale)
    love.graphics.drawq(gfx.image, hud.spr.lives, gfx.x + 128 + 64, 52, 0.0, gfx.scale, gfx.scale)
    love.graphics.drawq(gfx.image, hud.spr.level, gfx.x + 256 + 64 + 32, 16, 0.0, gfx.scale, gfx.scale)

    love.graphics.printf("3", gfx.x + 256, 48, 0, "left")
    love.graphics.printf("1", gfx.x + 256 + 128 + 4, 48, 0, "center" )
    love.graphics.printf("100,000,000", gfx.width - 24, 48, 0, "right")
end

-- ****************************************
--   Game
-- ****************************************


function initScoreHandler()
    scoreHandler = {}
    scoreHandler.score = 0
    scoreHandler.level = 1
    
    -- Define speeds for all 9 levels
    for i=1, 9 do scoreHandler[i] = {} end
    scoreHandler[1].snakeSpeed = 0.25
    scoreHandler[2].snakeSpeed = 0.225
    scoreHandler[3].snakeSpeed = 0.20
    scoreHandler[4].snakeSpeed = 0.175
    scoreHandler[5].snakeSpeed = 0.15
    scoreHandler[6].snakeSpeed = 0.125
    scoreHandler[7].snakeSpeed = 0.10
    scoreHandler[8].snakeSpeed = 0.075
    scoreHandler[9].snakeSpeed = 0.050

    -- Define score requirements for level-ups
    scoreHandler[1].level = 0
    scoreHandler[2].level = 10
    scoreHandler[3].level = 20
    scoreHandler[4].level = 30
    scoreHandler[5].level = 40
    scoreHandler[6].level = 50
    scoreHandler[7].level = 60
    scoreHandler[8].level = 70
    scoreHandler[9].level = 80

end

-- ****************************************
--   Snake
-- ****************************************

function initSnake()
    snake = {}
    
    -- Badger badger badger badger SNAAAAKE
    snake.x = map.px
	snake.y = map.py
    snake.vx = 1
    snake.vy = 0
    snake.pvx = 1  -- previous snake velocity
    snake.pvy = 0
    snake.time = 0.0
    snake.speed = scoreHandler[1].snakeSpeed
    snake.body = spr.snake
    snake.head = spr.snakeE
    
    -- Populate snake with bodies
    snakeSize(snake, 4)
    
end

function initEnemy()
    enemy = {}
    
    enemy.x = map.ex
    enemy.y = map.ey
    enemy.vx = -1
    enemy.vy = 0
    enemy.pvx = -1  -- previous snake velocity
    enemy.pvy = 0
    enemy.time = 0.0
    enemy.speed = scoreHandler[1].snakeSpeed
    enemy.body = spr.enemy
    enemy.head = spr.enemyW
    
    -- Populate snake with bodies
    snakeSize(enemy, 4)
    
end

function updateSnake(dt)
    local s = snake
    local i
    
    -- Snake input
    if love.keyboard.isDown("left") and s.pvx ~= 1 then turnSnake(snake, -1,0)
    elseif love.keyboard.isDown("right") and s.pvx ~= -1 then turnSnake(snake, 1,0)
    elseif love.keyboard.isDown("up") and s.pvy ~= 1 then turnSnake(snake, 0,-1)
    elseif love.keyboard.isDown("down") and s.pvy ~= -1 then turnSnake(snake, 0,1) end
    
    -- Can move?
    if s.time <= 0.0 then
        s.time = s.speed
        
        -- Move the snake
        local body = {}
        body.x = s.x
        body.y = s.y
        table.insert(snake, body)

        s.x = s.x + s.vx
        s.y = s.y + s.vy
        s.pvx = s.vx
        s.pvy = s.vy
   
        if s.vx == -1 then s.head = spr.snakeW
        elseif s.vx == 1 then s.head = spr.snakeE
        elseif s.vy ==-1 then s.head = spr.snakeN
        elseif s.vy == 1 then s.head = spr.snakeS end
		
		-- Solid collision
		if solidTouch(s.x, s.y) then
			gameQuit()
		end
        
        -- Fruit collision
        if s.x == fruit.x and s.y == fruit.y then
            scoreHandler.score = scoreHandler.score + 1
            local nextlevel = scoreHandler.level + 1
            if scoreHandler[nextlevel].level <= scoreHandler.score then
                scoreHandler.level = scoreHandler.level + 1
                snake.speed = scoreHandler[nextlevel].snakeSpeed
            end
            newFruit()
        else
            table.remove(snake, 1)
        end
        
        -- Self collision
        for i=1, table.getn(s) do
            if s.x == s[i].x and s.y == s[i].y then
                gameQuit()
            end
        end
            
    else
        s.time = s.time - dt
    end
end

function updateEnemy(dt)
	--[[
	
    local s = snake
    local i
    
    -- Snake input
    if love.keyboard.isDown("left") and s.pvx ~= 1 then turnSnake(-1,0)
    elseif love.keyboard.isDown("right") and s.pvx ~= -1 then turnSnake(1,0)
    elseif love.keyboard.isDown("up") and s.pvy ~= 1 then turnSnake(0,-1)
    elseif love.keyboard.isDown("down") and s.pvy ~= -1 then turnSnake(0,1) end
    
    -- Can move?
    if s.time <= 0.0 then
        s.time = s.speed
        
        -- Move the snake
        local body = {}
        body.x = s.x
        body.y = s.y
        table.insert(snake, body)

        s.x = s.x + s.vx
        s.y = s.y + s.vy
        s.pvx = s.vx
        s.pvy = s.vy
   
        if s.vx == -1 then s.head = spr.snakeW
        elseif s.vx == 1 then s.head = spr.snakeE
        elseif s.vy ==-1 then s.head = spr.snakeN
        elseif s.vy == 1 then s.head = spr.snakeS end

        -- Wall collision
        local w, h = 1+game.width, 1+game.height
        if s.x < 1    or s.x >= w or s.y < 1 or s.y >= h then
            gameQuit()
        end        
        
        -- Block collision
        if blockTouch(s.x, s.y) then
            gameQuit()
        end
        
        -- Fruit collision
        if s.x == fruit.x and s.y == fruit.y then
            scoreHandler.score = scoreHandler.score + 1
            local nextlevel = scoreHandler.level + 1
            if scoreHandler[nextlevel].level <= scoreHandler.score then
                scoreHandler.level = scoreHandler.level + 1
                snake.speed = scoreHandler[nextlevel].snakeSpeed
            end
            newFruit()
        else
            table.remove(snake, 1)
        end
        
        -- Self collision
        for i=1, table.getn(s) do
            if s.x == s[i].x and s.y == s[i].y then
                gameQuit()
            end
        end
            
    else
        s.time = s.time - dt
    end
											]]--
	end



function turnSnake(theSnake, x,y)
	theSnake.vx = x
    theSnake.vy = y
end

function drawSnake(theSnake,x,y)
    local s = theSnake
    
    drawTile(s.head, s.x, s.y)
    
    for i=1, table.getn(s) do
        drawTile(s.body, s[i].x, s[i].y)
    end
end

function snakeTouch(x,y)
    local s = snake
    local i
    
    if x == s.x and y == s.y then
        return true
    end
    
    for i=1, table.getn(s) do
        if x == s[i].x and y == s[i].y then
            return true
        end
    end
    
    return false
end

function snakeSize(theSnake, n)
    local body, i
    
    for i=0, n-1 do
        body = {}
				
		if theSnake.vx == 0 and theSnake.vy == -1 then -- North
			body.x = theSnake.x
			body.y = theSnake.y + (n-i)
		elseif theSnake.vx == 1 and theSnake.vy == 0 then -- East
			body.x = theSnake.x - (n-i)
			body.y = theSnake.y
		elseif theSnake.vx == 0 and theSnake.vy == 1 then -- South
			body.x = theSnake.x
			body.y = theSnake.y - (n-i)
		elseif theSnake.vx == -1 and theSnake.vy == 0 then -- West
			body.x = theSnake.x + (n-i)
			body.y = theSnake.y
		end
        table.insert(theSnake, body)
    end
end

-- ****************************************
--  Fruit
-- ****************************************

function initFruit()
    fruit = {}
    
    -- Random seed
    math.randomseed( os.time() )
    math.random()
    
    -- Set fruit to maximum initialized state. Engage.
    newFruit()
end

function newFruit()
    local s = snake
    local f = fruit
    
    -- Ensure fruit spawns in empty space
    local loop = true
    while loop do
        loop = false
        
        -- Randomize fruit
        f.x = math.random(1, map.w)
        f.y = math.random(1, map.h)
		
        -- Hello ladies. Look at your loop. Now back to mine. THE COLLISION CHECKING IS NOW SIMPLIFIED AND MORE COMPACT
        if snakeTouch(f.x, f.y) then
            loop = true
        elseif solidTouch(f.x, f.y) then
            loop = true
		else
			n = 0
			if solidTouch(f.x, f.y-1) then n = n+1 end
			if solidTouch(f.x+1, f.y) then n = n+1 end
			if solidTouch(f.x, f.y+1) then n = n+1 end
			if solidTouch(f.x-1, f.y) then n = n+1 end
			
			if n >= 2 then
				loop = true
			end
        end
        
    end
end

function drawFruit()
    drawTile(spr.fruit, fruit.x, fruit.y)
end

-- ****************************************
--   Map
-- ****************************************

function t2s(t)
	local x, y
	local w = 16 -- gfx.image:getWidth() / gfx.tile
	
	x = t % w
	y = (t - x) / w
			
	return x+1, y+1
end

function s2t(x,y)
	return (x-1) + (y-1) * 16 -- gfx.image:getWidth() / gfx.tile
end

function initMap(m)
	local x, y
	
	map = m
	
	map.px = map.px + 1
	map.py = map.py + 1
	map.ex = map.ex + 1
	map.ey = map.ey + 1
	
	-- Init a 2D collision array to "solid" state
	solid = {}
	
	for x=1, map.w do
        solid[x] = {}
        for y=1, map.h do
           solid[x][y] = 1
        end
    end
	
	solid.w = map.w
	solid.h = map.h
	
	-- Chisel away where the "empty" tiles are
	for x=1, map.w do
        for y=1, map.h do
			local t = map[y][x]
			
			if t == s2t(1,3) or t == s2t(2,3) or t == s2t(3,3) or t == s2t(5,3) or
				t == s2t(1,4) or t == s2t(2,4) or t == s2t(3,4) then 
			
				solid[x][y] = 0
		
			end	
		end
	end
end

function drawMap()
	local x, y
	local i, j
	
	for x=1, map.w do
        for y=1, map.h do
			i, j = t2s(map[y][x])
			drawTile(gfx.sprites[i][j], x, y)
		end
	end
end

function solidTouch(x,y)
	if solid[x][y] == 1 then
		return true
	else
		return false
	end
end

function drawShadows()
    local i, x, y
    local nw, n, w
    
    for x=3, map.w-2 do
        for y=3, map.h-2 do
			if solid[x][y] == 0 then
        
				-- Snake shadow
				nw = snakeTouch(x-1, y-1)
				n = snakeTouch(x, y-1)
				w = snakeTouch(x-1,y)
				
				if nw and not n and not w then
					drawTile(gfx.sprites[3][5], x, y)
				elseif w and n then
					drawTile(gfx.sprites[1][5], x, y)
				elseif w then
					drawTile(gfx.sprites[1][6], x, y)
				elseif n then
					drawTile(gfx.sprites[2][5], x, y)
				end
				
			end
        end
    end
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
