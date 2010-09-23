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

images = {}

function loadImage(name,file)
	local img = love.graphics.newImage(file)
	img:setFilter("nearest", "nearest")
	images[name] = img
	return img
end

function getImage(name)
	return images[name]
end