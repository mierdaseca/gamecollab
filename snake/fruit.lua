-- ==================================================
--
--     fruit.lua
--
--
--
-- ==================================================

-- ****************************************
--   Fruit
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
