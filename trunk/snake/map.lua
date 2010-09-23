-- ==================================================
--
--     map.lua
--
--
--
-- ==================================================

require("maps/map01.lua")
require("maps/map02.lua")

-- ****************************************
--   Map
-- ****************************************

function initMap()
	local x, y
	
	-- Load map01.lua
	map = map01
	
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

function solidTouch(x,y)
	if solid[x][y] == 1 then
		return true
	else
		return false
	end
end

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