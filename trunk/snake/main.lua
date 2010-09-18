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

-- TODO:
--
--   + The graphics
--   + The video game
--   + Coffee
--   + Show /r/RMAG how it's done. LIKE A BOSS
--   - My ass hurts from this chair
--

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
    spr.fruit = gfx.sprites[4][3]
    spr.block = gfx.sprites[4][4]
    
    game = {}
    game.width = 30
    game.height = 18
    
    view = {}
    view.x = -4
    view.y = 0
    view.w = (gfx.width / gfx.tile) / gfx.scale
    view.h = (gfx.height / gfx.tile) / gfx.scale
    view.pad = 6
    
    initScoreHandler()
    initSnake()
    initBlocks()
    initFruit()
    initBorder()
    initHud()
end

function love.update(dt)
    updateSnake(dt)
    updateView(dt)
end

function love.draw()
    drawGround()
    drawSnake()
    drawFruit()
    drawBlocks()
    drawBorder()
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
    snake.x = 5
    snake.y = 2
    snake.vx = 1
    snake.vy = 0
    snake.pvx = 1  -- previous snake velocity
    snake.pvy = 0
    snake.time = 0.0
    snake.speed = scoreHandler[1].snakeSpeed
    snake.body = spr.snake
    snake.head = spr.snakeE
    
    -- Populate snake with bodies
    snakeSize(4)
    
end

function updateSnake(dt)
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
end

function turnSnake(x,y)
    snake.vx = x
    snake.vy = y
end

function drawSnake(x,y)
    local s = snake
    
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

function snakeSize(n)
    local body, i
    
    for i=0, n-1 do
        body = {}
        body.x = snake.x - (n-i)
        body.y = snake.y
        table.insert(snake, body)
    end
end

-- ****************************************
--   Blocks
-- ****************************************

function initBlocks()
    blocks = {}
    
    -- Block map
    map =
    {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0 },
        { 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    }
        
    map.w = 30
    map.h = 18

    local x, y
    for x=1, map.w do
        for y=1, map.h do
            if map[y][x] == 1 then  
                newBlock(x, y)
            end
        end
    end
end

function newBlock(x, y)
    local i
    local b = blocks

    -- Disallow dirty, filthy clones
    for i=1, table.getn(b) do
        if x == b[i].x and b[i].y == y then
            return
        end
    end
    
    -- Create new block
    b = {}
    b.x = x
    b.y = y
    table.insert(blocks, b)
end

function drawBlocks()
    local i
    local b = blocks
    
    for i=1, table.getn(b) do
        drawTile(spr.block, b[i].x, b[i].y)
    end
end

function blockTouch(x,y)
    local i
    local b = blocks
    
    for i=1, table.getn(b) do
        if x == b[i].x and y == b[i].y then
            return true
        end
    end
    
    return false
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
        f.x = math.random(1, game.width-1)
        f.y = math.random(1, game.height-1)
        
        -- Hello ladies. Look at your loop. Now back to mine. THE COLLISION CHECKING IS NOW SIMPLIFIED AND MORE COMPACT
        if snakeTouch(f.x, f.y) then
            loop = true
        elseif blockTouch(f.x, f.y) then
            loop = true
        end
        
    end
end

function drawFruit()
    drawTile(spr.fruit, fruit.x, fruit.y)
end

-- ****************************************
--   Map
-- ****************************************

function drawGround()
    local i, x, y
    local nw, n, w
    
    -- Draw ground
    drawTile(gfx.sprites[1][3], 1, 1)
    for i=2, game.width do drawTile(gfx.sprites[2][3], i, 1) end
    for i=2, game.height do drawTile(gfx.sprites[1][4], 1, i) end
    for x=2, game.width do
        for y=2, game.height do
        
            -- Block shadow
            nw = blockTouch(x-1, y-1)
            n = blockTouch(x, y-1)
            w = blockTouch(x-1,y)
            
            if w and n then
                drawTile(gfx.sprites[1][3], x, y)
            elseif not nw and n then
                drawTile(gfx.sprites[2][4], x, y)
            elseif not nw and w then
                drawTile(gfx.sprites[3][4], x, y)
            elseif nw and not n and not w then
                drawTile(gfx.sprites[3][3], x, y)
            elseif w then
                drawTile(gfx.sprites[1][4], x, y)
            elseif n then
                drawTile(gfx.sprites[2][3], x, y)
            else
                drawTile(gfx.sprites[5][3], x, y)
            end
                
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

function initBorder()
    local img = gfx.image
    local w, h = img:getWidth(), img:getHeight()
    local t = gfx.tile
    local x, y = 5, -3
    
    leaves = {}
    
    leaves.NW = { img, love.graphics.newQuad((x+0)*t, (y+3)*t, 32, 32, w, h) }
    leaves.N  = { img, love.graphics.newQuad((x+2)*t, (y+3)*t, 16, 32, w, h) }
    leaves.NE = { img, love.graphics.newQuad((x+3)*t, (y+3)*t, 32, 32, w, h) }
    
    leaves.W1 = { img, love.graphics.newQuad((x+0)*t, (y+5)*t, 32, 16, w, h) }
    leaves.W2  ={ img, love.graphics.newQuad((x+0)*t, (y+6)*t, 32, 16, w, h) }
    leaves.W3 = { img, love.graphics.newQuad((x+0)*t, (y+7)*t, 32, 16, w, h) }
    
    leaves.E1 = { img, love.graphics.newQuad((x+3)*t, (y+5)*t, 32, 16, w, h) }
    leaves.E2  = { img, love.graphics.newQuad((x+3)*t, (y+6)*t, 32, 16, w, h) }
    leaves.E3 = { img, love.graphics.newQuad((x+3)*t, (y+7)*t, 32, 16, w, h) }
    
    leaves.SW = { img, love.graphics.newQuad((x+0)*t, (y+8)*t, 32, 32, w, h) }
    leaves.S  = { img, love.graphics.newQuad((x+2)*t, (y+8)*t, 16, 32, w, h) }
    leaves.SE = { img, love.graphics.newQuad((x+3)*t, (y+8)*t, 32, 32, w, h) }
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
