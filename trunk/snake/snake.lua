-- ==================================================
--
--     snake.lua
--
--
--
-- ==================================================

-- ****************************************
--   Snake
-- ****************************************

function initSnake()
    snake = {}
    
    -- Badger badger badger badger SNAAAAKE
    snake.x = map.px + 1
	snake.y = map.py + 1
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
    
    enemy.x = map.ex + 1
    enemy.y = map.ey + 1
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
			gameDie()
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
                gameDie()
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
