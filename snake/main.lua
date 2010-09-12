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
	love.graphics.setBackgroundColor(23,12,0)

	gfx = {}
	gfx.image = love.graphics.newImage("snake.png")
	gfx.image:setFilter("nearest", "nearest")
	gfx.scale = 2
	gfx.tile = 16
	gfx.x = 2 * gfx.tile
	gfx.y = 2 * gfx.tile
	gfx.sprites = spriteSheet(gfx.tile, gfx.image)
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

	spr.tree1 = gfx.sprites[2][5]
	spr.tree2 = gfx.sprites[3][5]
	spr.tree3 = gfx.sprites[4][5]
	spr.tree4 = gfx.sprites[4][6]
	
	game = {}
	game.width = 20
	game.height = 12
	
	initSnake()
end

function love.update(dt)
	updateSnake(dt)
end

function love.draw()
	drawGround()
	drawSnake()
	drawTile(spr.fruit, 10, 5)
	drawBlocks()
end

function love.keypressed(key)
	if key == "escape" or key == "q" then
		love.event.push("q")
	elseif key == "r" then
		love.filesystem.load("main.lua")()
		love.load()
	end
end

-- *******
--  snake
-- *******

function initSnake()
	snake = {}
	snake.x = 0
	snake.y = 0
	snake.vx = 1
	snake.vy = 0
	snake.time = 0.0
	snake.speed = 0.25
end

function updateSnake(dt)
	local s = snake
	
	-- Snake input
	if love.keyboard.isDown("left") then
		turnSnake(-1,0)
	elseif love.keyboard.isDown("right") then
		turnSnake(1,0)
	elseif love.keyboard.isDown("up") then
		turnSnake(0,-1)
	elseif love.keyboard.isDown("down") then
		turnSnake(0,1)
	end
	
	-- Move the snake
	if s.time <= 0.0 then
		s.time = s.speed
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
	drawTile(spr.snake, s.x, s.y)
end

-- *****
--  map
-- *****

function drawGround()
	local i, j
	
	-- Draw ground
	
	drawTile(spr.floor2, 1, 1)
	
	for i=2, game.width do
		drawTile(spr.floor3, i, 1)
	end
	for j=2, game.height do
		drawTile(spr.floor1, 1, j)
	end
	for i=2, game.width do
		for j=2, game.height do
			drawTile(spr.floor, i, j)
		end
	end
	
end

function drawBlocks()
	local i, j
	local w, h = game.width, game.height

	-- Draw walls
	
	--[[
	drawTile(spr.tree1, 0, 0)
	for i=0, w do
		drawTile(spr.tree2, i, 0)
	end
	drawTile(spr.tree3, w+1, 0)
	--]]
	
	--[[
	for i=0, game.width+1 do
		drawTile(spr.block, i, 0)
		drawTile(spr.block, i, game.height+1)
	end

	for j=0, game.height+1 do
		drawTile(spr.block, 0, j)
		drawTile(spr.block, game.width+1, j)
	end
	--]]

end

-- ******************
--  helper functions
-- ******************

function drawTile(spr,x,y)
	drawSprite(spr, x*gfx.tile, y*gfx.tile)
end

function drawSprite(sprite,x,y)
	love.graphics.drawq(sprite[1], sprite[2], (x+gfx.x)*gfx.scale, (y+gfx.y)*gfx.scale, 0.0, gfx.scale, gfx.scale)
end

function spriteSheet(t,i)
	local i, j
	local tab = {}
	local w, h = i:getWidth(), i:getHeight()
	local x, y = (w/t), (h/t)	
	
	for i=1, x do
		tab[i] = {}
		for j=1, y do
			tab[i][j] = { i, love.graphics.newQuad((i-1)*t, (j-1)*t, t, t, w, h) }
		end
	end

	return tab
end
