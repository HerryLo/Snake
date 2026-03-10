-- main.lua
Utils = require("utils")
Snake = require("snake")
Food = require("food")
Leaderboard = require("leaderboard")
Game = require("game")
UI = require("ui")

local game

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Snake Game")
    
    game = Game:new()
    
    print("=== Snake Game Started ===")
    print("Controls:")
    print("  Arrow Keys: Move")
    print("  P: Pause/Resume")
    print("  L or TAB: Leaderboard")
    print("  SPACE: Restart (saves score)")
    print("  ESC: Quit/Back")
    print("Current state: " .. game.state)
    print("Leaderboard will be saved to: " .. game.leaderboard:getFilePath())
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(Utils.colors.background)
    
    if game.state == "leaderboard" then
        UI.drawLeaderboard(game)
    else
        UI.drawGrid()
        UI.drawFood(game.food)
        UI.drawSnake(game.snake)
        UI.drawUI(game)
        
        if game.state == "start" then
            UI.drawStartScreen()
        elseif game.state == "paused" then
            UI.drawPauseScreen()
        elseif game.state == "gameover" then
            UI.drawGameOverScreen(game)
        end
    end
end

function love.keypressed(key)
    -- 转换tab键为字符串
    if key == "tab" then
        key = "tab"
    end
    
    -- 调试输出
    print("Key pressed: " .. tostring(key) .. " | Game state: " .. game.state)
    
    -- 处理按键
    game:handleInput(key)
end

function love.mousepressed(x, y, button)
    if game.state == "start" then
        game:start()
    end
end

-- 退出时确保保存
function love.quit()
    print("Game shutting down...")
    if game and game.score > 0 and game.state == "gameover" then
        game:saveToLeaderboard()
    end
end