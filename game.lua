-- game.lua
local Game = {}
Game.__index = Game

function Game:new()
    local game = {
        state = "start",
        score = 0,
        moveTimer = 0,
        moveInterval = Utils.initialSpeed,
        snake = Snake:new(),
        food = Food:new(),
        leaderboard = Leaderboard:new(10),
        gameOverTimer = 0
    }
    setmetatable(game, Game)
    
    game.food:generate(game.snake:getBody())
    
    -- 调试信息
    print("Leaderboard file path: " .. game.leaderboard:getFilePath())
    
    return game
end

function Game:update(dt)
    if self.state == "playing" then
        self.moveTimer = self.moveTimer + dt
        
        if self.moveTimer >= self.moveInterval then
            self.moveTimer = self.moveTimer - self.moveInterval
            self:moveSnake()
        end
    end
end

function Game:moveSnake()
    local currentDir = self.snake.direction
    local head = self.snake:getHead()
    local newHead = {x = head.x, y = head.y}
    
    if currentDir == "right" then
        newHead.x = newHead.x + 1
    elseif currentDir == "left" then
        newHead.x = newHead.x - 1
    elseif currentDir == "up" then
        newHead.y = newHead.y - 1
    elseif currentDir == "down" then
        newHead.y = newHead.y + 1
    end
    
    local ateFood = self.food:checkEaten(newHead.x, newHead.y)
    
    table.insert(self.snake.body, 1, newHead)
    
    if ateFood then
        self.score = self.score + 10
        self.moveInterval = Utils.calculateSpeed(self.score)
        self.food:generate(self.snake:getBody())
        
        if self.snake:getLength() >= Utils.gridWidth * Utils.gridHeight then
            self:gameOver()
        end
    else
        table.remove(self.snake.body)
    end
    
    self:checkCollision()
end

function Game:checkCollision()
    local head = self.snake:getHead()
    
    if not Utils.isValidPosition(head.x, head.y) then
        self:gameOver()
        return
    end
    
    if self.snake:checkSelfCollision() then
        self:gameOver()
        return
    end
end

function Game:gameOver()
    self.state = "gameover"
    self.gameOverTimer = 0
    
    -- 检查是否进入排行榜
    if self.leaderboard:isHighScore(self.score) then
        local playerName = Utils.generateRandomName()
        self.leaderboard:setPlayerName(playerName)
        print("New high score! Name: " .. playerName .. ", Score: " .. self.score)
    end
    
    print("Game over! Score: " .. self.score)
end

-- 保存分数到排行榜
function Game:saveToLeaderboard()
    if self.score > 0 then
        -- 如果没有玩家名称，生成一个
        if self.leaderboard:getPlayerName() == "" then
            self.leaderboard:setPlayerName(Utils.generateRandomName())
        end
        
        -- 添加到排行榜
        self.leaderboard:addEntry(
            self.leaderboard:getPlayerName(),
            self.score
        )
        
        -- 重新加载排行榜以确保显示最新数据
        self.leaderboard:load()
        
        print("Score " .. self.score .. " saved to leaderboard with name: " .. self.leaderboard:getPlayerName())
    else
        print("Score is 0, not saving to leaderboard")
    end
end

function Game:restart()
    -- 确保任何未保存的分数都被保存
    if self.score > 0 and self.state == "gameover" then
        self:saveToLeaderboard()
    end
    
    self.state = "playing"
    self.score = 0
    self.moveInterval = Utils.initialSpeed
    self.moveTimer = 0
    self.snake:reset()
    self.food:generate(self.snake:getBody())
    print("Game restarted")
end

function Game:start()
    self.state = "playing"
    print("Game started")
end

function Game:pause()
    if self.state == "playing" then
        self.state = "paused"
        return true
    end
    return false
end

function Game:resume()
    if self.state == "paused" then
        self.state = "playing"
        return true
    end
    return false
end

function Game:togglePause()
    if self.state == "playing" then
        self.state = "paused"
        print("Game paused")
    elseif self.state == "paused" then
        self.state = "playing"
        print("Game resumed")
    end
end

function Game:showLeaderboard()
    -- 重新加载排行榜以确保显示最新数据
    self.leaderboard:load()
    self.state = "leaderboard"
    print("Showing leaderboard with " .. #self.leaderboard:getEntries() .. " entries")
end

function Game:handleInput(key)
    print(key);
    -- 处理ESC键
    if key == "escape" then
        if self.state == "leaderboard" then
            self.state = "gameover"
            print("Returning to gameover from leaderboard")
        elseif self.state == "paused" then
            self.state = "playing"
            print("Returning to game from pause")
        else
            love.event.quit()
        end
        return
    end
    
    -- 根据当前状态处理按键
    if self.state == "start" then
        -- 开始界面：任何键开始游戏
        self:start()
        
    elseif self.state == "playing" then
        -- 游戏中的按键处理
        if key == "p" then
            self:togglePause()
        elseif key == "l" or key == "tab" then
            self:showLeaderboard()
        elseif key == "right" or key == "left" or key == "up" or key == "down" then
            self.snake:updateDirection(key)
        end
        
    elseif self.state == "paused" then
        -- 暂停中的按键处理
        if key == "p" then
            self:togglePause()
        elseif key == "l" or key == "tab" then
            self:showLeaderboard()
        elseif key == "space" then
            self:restart()
        end
        
    elseif self.state == "gameover" then
        -- 游戏结束的按键处理
        if key == "space" then
            self:restart()
        elseif key == "l" or key == "tab" then
            self:showLeaderboard()
        end
        
    elseif self.state == "leaderboard" then
        -- 排行榜的按键处理
        if key == "space" then
            self:restart()
        elseif key == "escape" then
            self.state = "gameover"
        end
    end
end

return Game