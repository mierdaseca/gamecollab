-- ==================================================
--
--     draw.lua
--
--
--
-- ==================================================

-- ****************************************
--  Draw Stuff
-- ****************************************

function drawTile(sprite,x,y)
    drawSprite(sprite, (x-1)*gfx.tile, (y-1)*gfx.tile)
end

function drawSprite(sprite,x,y)
    x = (x*gfx.scale) - view.x
    y = (y*gfx.scale) - view.y
    love.graphics.drawq(sprite[1], sprite[2], x, y, 0.0, gfx.scale, gfx.scale)
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

function drawBumper(b,x,y,str)	
	if str == "middle" then
		love.graphics.drawq(b.img, b.quad, x-b.w*.5, y, 0.0, gfx.scale, gfx.scale)
	elseif str == "center" then
		love.graphics.drawq(b.img, b.quad, x-b.w*.5, y-b.h*0.5, 0.0, gfx.scale, gfx.scale)
	elseif str == "left" then
		love.graphics.drawq(b.img, b.quad, x, y, 0.0, gfx.scale, gfx.scale)
	elseif str == "right" then
		love.graphics.drawq(b.img, b.quad, x-b.w, y, 0.0, gfx.scale, gfx.scale)
	end
end

function loadImage(file)
	local img = love.graphics.newImage(file)
	img:setFilter("nearest", "nearest")
	return img
end

function loadBumper(img,x,y,w,h)
	local bx, by, bw, bh
	bx = x * gfx.tile
	by = y * gfx.tile
	bw = math.ceil(w) * gfx.tile
	bh = math.ceil(h) * gfx.tile
	
	local b = {}
	b.img = img
	b.quad = love.graphics.newQuad(bx, by, bw, bh, img:getWidth(), img:getHeight())
	b.w = w * (gfx.tile * gfx.scale)
	b.h = h * (gfx.tile * gfx.scale)
	return b
end