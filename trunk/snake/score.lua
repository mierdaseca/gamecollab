-- ==================================================
--
--     score.lua
--
--
--
-- ==================================================

-- ****************************************
--   ScoreHandler
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