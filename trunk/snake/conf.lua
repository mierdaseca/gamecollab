-- ==============================
--
--     conf.lua
--
--
--
-- ==============================

function love.conf(t)
    t.modules.joystick = false 	-- Enable the joystick module (boolean)
    t.modules.audio = false		-- Enable the audio module (boolean)
    t.modules.keyboard = true		-- Enable the keyboard module (boolean)
    t.modules.event = true			-- Enable the event module (boolean)
    t.modules.image = true			-- Enable the image module (boolean)
    t.modules.graphics = true		-- Enable the graphics module (boolean)
    t.modules.timer = true			-- Enable the timer module (boolean)
    t.modules.mouse = false		-- Enable the mouse module (boolean)
    t.modules.sound = false		-- Enable the sound module (boolean)
    t.modules.physics = false		-- Enable the physics module (boolean)
    t.console = false				-- Attach a console (boolean, Windows only)
    t.title = "Snake"				-- The title of the window the game is in (string)
    t.author = "/r/gamecollab"		-- The author of the game (string)
    t.screen.fullscreen = false	-- Enable fullscreen (boolean)
    t.screen.vsync = true			-- Enable vertical sync (boolean)
    t.screen.fsaa = 0				-- The number of FSAA-buffers (number)
	t.screen.width = 800			-- The window width (number)
    t.screen.height = 600			-- The window height (number)
    t.version = 0					-- The LÖVE version this game was made for (number)
end