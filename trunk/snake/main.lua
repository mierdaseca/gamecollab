-- ==============================
--
--     main.lua
--
--
--
-- ==============================

-- Don't forget that Lua arrays begin at 1!
-- "for i=1, 10 do" is a range of 1 to 10
-- different to how arrays are iterated in C:
-- "for( i=0; i<10; i++ )" range of 0 to 9

-- ******
--  love
-- ******

function love.load()
	
	--require("proAudioRt")
	--proAudio.create(16,44100,1024)
	--sample = proAudio.sampleFromFile("snake/snake_battle.mp3")
	--if sample then bgm = proAudio.soundLoop(sample) end
	
	love.graphics.setBackgroundColor(33, 21, 0)
	
	gfx = {}
	gfx.image = love.graphics.newImage("snake.png")
	gfx.image:setFilter("nearest", "nearest")
	gfx.scale = 2
	gfx.tile = 16
	gfx.x = 2 * gfx.tile - (gfx.tile/2)
	gfx.y = 2 * gfx.tile
	gfx.sprites = spriteSheet(gfx.image, gfx.tile)
	gfx.width = love.graphics.getWidth()
	gfx.height = love.graphics.getHeight()

	spr = {}
	spr.snake = gfx.sprites[1][2]
	spr.block = gfx.sprites[1][3]
	spr.floor = gfx.sprites[3][3]
	spr.floor1= gfx.sprites[2][3] 
	spr.floor2= gfx.sprites[2][2]
	spr.floor3= gfx.sprites[3][2]
	spr.fruit = gfx.sprites[4][3]
	
	game = {}
	game.width = 20
	game.height = 12
	
	--initScoreHandler()
	initFruit()
	initSnake()
	initBorder()
end

function love.update(dt)
	updateSnake(dt)
end

function love.draw()
	drawGround()
	drawSnake()
	drawFruit()
	drawBorder()
end

function love.keypressed(key)
	if key == "escape" or key == "q" then
		gameOver()
	elseif key == "r" then
		love.filesystem.load("main.lua")()
		love.load()
	end
end

-- *******
--  score
-- *******

function gameOver()
	love.event.push("q")	
end

--function initScoreHandler()
--	scoreHandler = {}
--	scoreHandler.level = 1
--	scoreHandler.snakeSpeed[1] = 0.25
--end

-- *******
--  snake
-- *******

function initSnake()
	snake = {}
	
	-- Bumped these in front of possible inserts
	snake.x = 0
	snake.y = 0
	snake.vx = 1
	snake.vy = 0
	snake.time = 0.0
	snake.speed = 0.15
	
	-- Ensure snake[i].x/y is not empty
	local body = {}
	body.x = 0
	body.y = 0
	table.insert(snake, body)
end

function updateSnake(dt)
	local s = snake
	
	-- Snake input
	if love.keyboard.isDown("left") and s.vx ~= 1 then turnSnake(-1,0)
	elseif love.keyboard.isDown("right") and s.vx ~= -1 then turnSnake(1,0)
	elseif love.keyboard.isDown("up") and s.vy ~= 1 then turnSnake(0,-1)
	elseif love.keyboard.isDown("down") and s.vy ~= -1 then turnSnake(0,1) end
	
	-- Move the snake
	if s.time <= 0.0 then
		s.time = s.speed
		
		local body = {}
		body.x = s.x
		body.y = s.y
		table.insert(snake, body)

		s.x = s.x + s.vx
		s.y = s.y + s.vy

		-- Wall collision
		local w, h = game.width, game.height
		
		if s.x < 1 then
			s.x = 1
		elseif s.x >= w then
			s.x = w
		end
		if s.y < 1 then
			s.y = 1
		elseif s.y >= h then
			s.y = h
		end		
		
		-- Self collision
		local i=1
		repeat
			-- Body collision check
			if s.x == s[i].x and s.y == s[i].y then
				gameOver()
			end
			i=i+1
		until i==table.getn(s)
		
		-- Fruit collision
		if s.x == fruit.x and s.y == fruit.y then
			newFruit()
		else
			table.remove(snake, 1)
		end
			
	else
		s.time = s.time - dt
	end
end

function turnSnake(x,y)
	snake.vx = x
	snake.vy = y
end

function drawSnake(x,y)
	local s = snake
	for i=1, table.getn(s) do
		drawTile(spr.snake, s[i].x, s[i].y)
	end
	drawTile(spr.snake, s.x, s.y)
end

-- *****
--  map
-- *****

function drawGround()
	local i, j
	local w, h = game.width, game.height
	
	-- Draw ground
	drawTile(spr.floor2, 1, 1)
	for i=2, w do drawTile(spr.floor3, i, 1) end
	for j=2, h do drawTile(spr.floor1, 1, j) end
	for i=2, w do
		for j=2, game.height do
			drawTile(spr.floor, i, j)
		end
	end
end

function initBorder()
	local img = gfx.image
	local w, h = img:getWidth(), img:getHeight()
	local t = gfx.tile
	
	leaves = {}
	
	leaves.NW = { img, love.graphics.newQuad(0, 3*t, 32, 32, w, h) }
	leaves.N  = { img, love.graphics.newQuad(2*t, 3*t, 16, 32, w, h) }
	leaves.NE = { img, love.graphics.newQuad(3*t, 3*t, 32, 32, w, h) }
	
	leaves.W1 = { img, love.graphics.newQuad(0, 5*t, 32, 16, w, h) }
	leaves.W2  = { img, love.graphics.newQuad(0, 6*t, 32, 16, w, h) }
	leaves.W3 = { img, love.graphics.newQuad(0, 7*t, 32, 16, w, h) }
	
	leaves.E1 = { img, love.graphics.newQuad(3*t, 5*t, 32, 16, w, h) }
	leaves.E2  = { img, love.graphics.newQuad(3*t, 6*t, 32, 16, w, h) }
	leaves.E3 = { img, love.graphics.newQuad(3*t, 7*t, 32, 16, w, h) }
	
	leaves.SW = { img, love.graphics.newQuad(0, 8*t, 32, 32, w, h) }
	leaves.S  = { img, love.graphics.newQuad(2*t, 8*t, 16, 32, w, h) }
	leaves.SE = { img, love.graphics.newQuad(3*t, 8*t, 32, 32, w, h) }
end

function drawBorder()
	local i, j
	local w, h = game.width, game.height
	local g = gfx.sprites
	
	-- Draw north border
	drawTile(leaves.NW, -1, -1)
	drawTile(leaves.NE, w+1, -1)
	for i=1, w do
		drawTile(leaves.N, i, -1)
	end
	
	-- Draw west border
	drawTile(leaves.W1, -1, 1)
	drawTile(leaves.W3, -1, h)
	for i=1, h-1 do
		drawTile(leaves.W2, -1, i)
	end
	
	-- Draw east border
	drawTile(leaves.E1, w+1, 1)
	drawTile(leaves.E3, w+1, h)
	for i=1, h-1 do
		drawTile(leaves.E2, w+1, i)
	end
	
	-- Draw south border
	drawTile(leaves.SW, -1, h+1)
	drawTile(leaves.SE, w+1, h+1)
	for i=1, w do
		drawTile(leaves.S, i, h+1)
	end
end

-- *****
-- Fruit
-- *****

function initFruit()
	fruit = {}
	
	-- Random seed
	math.randomseed( os.time() )
	math.random()
	
	fruit.x = math.random(1, game.width-1)
	fruit.y = math.random(1, game.height-1)
end

function newFruit()
	local s = snake
	local f = fruit
	
	-- Random seed
	math.randomseed( os.time() )
	math.random()
	
	-- Ensure fruit spawns in empty space
	local loop = true
	while loop do
		loop = false
		
		f.x = math.random(1, game.width-1)
		f.y = math.random(1, game.height-1)
		
		for i=1, table.getn(s) do
			if (f.x == s[i].x and f.y == s[i].y) or (f.x == s.x and f.y == s.y) then loop = true break end
		end
	end
end

function drawFruit()
	drawTile(spr.fruit, fruit.x, fruit.y)
end

-- ******************
--  helper functions
-- ******************

function drawTile(sprite,x,y)
	drawSprite(sprite, x*gfx.tile, y*gfx.tile)
end

function drawSprite(sprite,x,y)
	love.graphics.drawq(sprite[1], sprite[2], (x+gfx.x)*gfx.scale, (y+gfx.y)*gfx.scale, 0.0, gfx.scale, gfx.scale)
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
