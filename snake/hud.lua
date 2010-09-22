-- ==================================================
--
--     hud.lua
--
--
--
-- ==================================================

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