-- ui.lua
UI = {}

-- 绘制网格
function UI.drawGrid()
    local cellSize, offsetX, offsetY = Utils.calculateGridOffset()
    
    love.graphics.setColor(Utils.colors.grid)
    love.graphics.setLineWidth(1)
    
    for i = 0, Utils.gridWidth do
        love.graphics.line(
            offsetX + i * cellSize, offsetY,
            offsetX + i * cellSize, offsetY + Utils.gridHeight * cellSize
        )
    end
    
    for i = 0, Utils.gridHeight do
        love.graphics.line(
            offsetX, offsetY + i * cellSize,
            offsetX + Utils.gridWidth * cellSize, offsetY + i * cellSize
        )
    end
end

-- 绘制食物
function UI.drawFood(food)
    local cellSize, offsetX, offsetY = Utils.calculateGridOffset()
    local x, y = food:getPosition()
    
    -- 食物主体
    love.graphics.setColor(Utils.colors.food)
    love.graphics.circle("fill", 
        offsetX + (x - 0.5) * cellSize,
        offsetY + (y - 0.5) * cellSize,
        cellSize * 0.4
    )
    
    -- 食物高光
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.circle("fill",
        offsetX + (x - 0.5) * cellSize - 2,
        offsetY + (y - 0.5) * cellSize - 2,
        cellSize * 0.15
    )
end

-- 绘制蛇
function UI.drawSnake(snake)
    local cellSize, offsetX, offsetY = Utils.calculateGridOffset()
    local body = snake:getBody()
    local direction = snake.direction
    
    -- 绘制蛇身
    for i = 2, #body do
        local segment = body[i]
        
        -- 蛇身主体
        love.graphics.setColor(Utils.colors.snakeBody[1], Utils.colors.snakeBody[2], 
                              Utils.colors.snakeBody[3], 0.8)
        love.graphics.rectangle("fill",
            offsetX + (segment.x - 1) * cellSize + 3,
            offsetY + (segment.y - 1) * cellSize + 3,
            cellSize - 6,
            cellSize - 6,
            5
        )
        
        -- 蛇身高光
        love.graphics.setColor(0.3, 0.9, 0.5, 0.3)
        love.graphics.rectangle("fill",
            offsetX + (segment.x - 1) * cellSize + 5,
            offsetY + (segment.y - 1) * cellSize + 5,
            cellSize - 10,
            cellSize - 10,
            3
        )
    end
    
    -- 绘制蛇头
    if #body > 0 then
        local head = body[1]
        local headX = offsetX + (head.x - 0.5) * cellSize
        local headY = offsetY + (head.y - 0.5) * cellSize
        
        -- 蛇头底色
        love.graphics.setColor(Utils.colors.snakeHead)
        love.graphics.circle("fill", headX, headY, cellSize * 0.45)
        
        -- 蛇头高光
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.circle("fill", headX - 3, headY - 3, cellSize * 0.15)
        
        -- 眼睛
        love.graphics.setColor(Utils.colors.snakeHeadEyes)
        
        local eyeOffset = cellSize * 0.2
        local pupilOffset = cellSize * 0.1
        
        if direction == "right" then
            -- 右眼
            love.graphics.circle("fill", headX + eyeOffset, headY - eyeOffset/2, cellSize * 0.1)
            love.graphics.circle("fill", headX + eyeOffset, headY + eyeOffset/2, cellSize * 0.1)
            -- 瞳孔
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", headX + eyeOffset + pupilOffset, headY - eyeOffset/2 - 2, cellSize * 0.04)
            love.graphics.circle("fill", headX + eyeOffset + pupilOffset, headY + eyeOffset/2 - 2, cellSize * 0.04)
        elseif direction == "left" then
            -- 左眼
            love.graphics.circle("fill", headX - eyeOffset, headY - eyeOffset/2, cellSize * 0.1)
            love.graphics.circle("fill", headX - eyeOffset, headY + eyeOffset/2, cellSize * 0.1)
            -- 瞳孔
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", headX - eyeOffset - pupilOffset, headY - eyeOffset/2 - 2, cellSize * 0.04)
            love.graphics.circle("fill", headX - eyeOffset - pupilOffset, headY + eyeOffset/2 - 2, cellSize * 0.04)
        elseif direction == "up" then
            -- 上眼
            love.graphics.circle("fill", headX - eyeOffset/2, headY - eyeOffset, cellSize * 0.1)
            love.graphics.circle("fill", headX + eyeOffset/2, headY - eyeOffset, cellSize * 0.1)
            -- 瞳孔
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", headX - eyeOffset/2 - 2, headY - eyeOffset - pupilOffset, cellSize * 0.04)
            love.graphics.circle("fill", headX + eyeOffset/2 - 2, headY - eyeOffset - pupilOffset, cellSize * 0.04)
        elseif direction == "down" then
            -- 下眼
            love.graphics.circle("fill", headX - eyeOffset/2, headY + eyeOffset, cellSize * 0.1)
            love.graphics.circle("fill", headX + eyeOffset/2, headY + eyeOffset, cellSize * 0.1)
            -- 瞳孔
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", headX - eyeOffset/2 - 2, headY + eyeOffset + pupilOffset, cellSize * 0.04)
            love.graphics.circle("fill", headX + eyeOffset/2 - 2, headY + eyeOffset + pupilOffset, cellSize * 0.04)
        end
        
        -- 舌头（闪烁效果）
        if math.floor(love.timer.getTime() * 4) % 2 == 0 then
            love.graphics.setColor(1, 0.2, 0.2)
            if direction == "right" then
                love.graphics.line(headX + cellSize * 0.3, headY, headX + cellSize * 0.45, headY - 3)
                love.graphics.line(headX + cellSize * 0.3, headY, headX + cellSize * 0.45, headY + 3)
            elseif direction == "left" then
                love.graphics.line(headX - cellSize * 0.3, headY, headX - cellSize * 0.45, headY - 3)
                love.graphics.line(headX - cellSize * 0.3, headY, headX - cellSize * 0.45, headY + 3)
            elseif direction == "up" then
                love.graphics.line(headX, headY - cellSize * 0.3, headX - 3, headY - cellSize * 0.45)
                love.graphics.line(headX, headY - cellSize * 0.3, headX + 3, headY - cellSize * 0.45)
            elseif direction == "down" then
                love.graphics.line(headX, headY + cellSize * 0.3, headX - 3, headY + cellSize * 0.45)
                love.graphics.line(headX, headY + cellSize * 0.3, headX + 3, headY + cellSize * 0.45)
            end
        end
    end
end

-- 绘制游戏UI
function UI.drawUI(game)
    -- 分数显示
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Score: " .. game.score, 20, 20)
    
    -- 速度显示
    local speedPercent = ((Utils.initialSpeed - game.moveInterval) / 
                         (Utils.initialSpeed - Utils.maxSpeed)) * 100
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print(string.format("Speed: %.0f%%", speedPercent), 20, 50)
    
    -- 蛇身长度显示
    love.graphics.print("Length: " .. game.snake:getLength(), 20, 70)
    
    -- 状态显示（调试用）
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("State: " .. game.state, 20, 100)
    
    -- 控制说明
    love.graphics.setColor(Utils.colors.textDim)
    love.graphics.setFont(love.graphics.newFont(14))
    local controls = "Arrow: Move | P: Pause | L/TAB: Leaderboard | SPACE: Restart | ESC: Quit"
    love.graphics.print(controls, 20, love.graphics.getHeight() - 40)
end

-- 绘制开始界面
function UI.drawStartScreen()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- 半透明遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- 标题
    love.graphics.setColor(Utils.colors.snakeHead)
    love.graphics.setFont(love.graphics.newFont(48))
    local text = "SNAKE GAME"
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 - 80)
    
    -- 副标题
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(24))
    text = "Press any key to start"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 20)
    
    -- 控制说明
    love.graphics.setColor(Utils.colors.textDim)
    love.graphics.setFont(love.graphics.newFont(16))
    text = "Use Arrow Keys to control the snake"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 60)
end

-- 绘制暂停界面
function UI.drawPauseScreen()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- 半透明遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- 暂停标题
    love.graphics.setColor(Utils.colors.snakeHead)
    love.graphics.setFont(love.graphics.newFont(48))
    local text = "PAUSED"
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 - 60)
    
    -- 提示信息
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(24))
    
    text = "Press P to resume"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2)
    
    text = "Press L/TAB for Leaderboard"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 40)
    
    text = "Press SPACE to restart"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 80)
    
    text = "Press ESC to quit"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 120)
end

-- 绘制游戏结束界面
function UI.drawGameOverScreen(game)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- 半透明遮罩
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- 游戏结束标题
    love.graphics.setColor(Utils.colors.food)
    love.graphics.setFont(love.graphics.newFont(48))
    local text = "GAME OVER"
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 - 140)
    
    -- 最终分数
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(32))
    text = "Final Score: " .. game.score
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 - 60)
    
    -- 保存提示
    love.graphics.setColor(Utils.colors.gold)
    love.graphics.setFont(love.graphics.newFont(20))
    text = "Your score will be saved to leaderboard"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 - 20)
    
    -- 如果是高分，显示特殊提示
    if game.leaderboard:isHighScore(game.score) then
        love.graphics.setColor(Utils.colors.gold)
        love.graphics.setFont(love.graphics.newFont(24))
        text = "NEW HIGH SCORE!"
        textWidth = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 20)
        
        love.graphics.setColor(Utils.colors.text)
        love.graphics.setFont(love.graphics.newFont(20))
        text = "Your name: " .. game.leaderboard:getPlayerName()
        textWidth = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 50)
    end
    
    -- 操作提示
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(20))
    text = "Press SPACE to save and restart"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 100)
    
    text = "Press TAB to view Leaderboard"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 130)
    
    text = "Press ESC to quit"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight / 2 + 160)
end

-- 绘制排行榜界面
function UI.drawLeaderboard(game)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local entries = game.leaderboard:getEntries()
    
    -- 深色背景
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- 标题
    love.graphics.setColor(Utils.colors.snakeHead)
    love.graphics.setFont(love.graphics.newFont(48))
    local text = "LEADERBOARD"
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, 40)
    
    -- 副标题
    love.graphics.setColor(Utils.colors.textDim)
    love.graphics.setFont(love.graphics.newFont(16))
    text = string.format("Top %d Scores", game.leaderboard.maxEntries)
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, 90)
    
    -- 表头
    love.graphics.setColor(Utils.colors.text)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Rank", screenWidth * 0.15, 130)
    love.graphics.print("Name", screenWidth * 0.35, 130)
    love.graphics.print("Score", screenWidth * 0.6, 130)
    love.graphics.print("Date", screenWidth * 0.75, 130)
    
    -- 分割线
    love.graphics.setColor(Utils.colors.textDim)
    love.graphics.line(screenWidth * 0.1, 160, screenWidth * 0.9, 160)
    
    -- 显示排行榜条目
    if #entries == 0 then
        love.graphics.setColor(Utils.colors.textDim)
        love.graphics.setFont(love.graphics.newFont(24))
        text = "No records yet"
        textWidth = love.graphics.getFont():getWidth(text)
        love.graphics.print(text, (screenWidth - textWidth) / 2, 300)
    else
        for i, entry in ipairs(entries) do
            local y = 170 + i * 35
            
            -- 排名颜色
            if i == 1 then
                love.graphics.setColor(Utils.colors.gold)
            elseif i == 2 then
                love.graphics.setColor(Utils.colors.silver)
            elseif i == 3 then
                love.graphics.setColor(Utils.colors.bronze)
            else
                love.graphics.setColor(Utils.colors.text)
            end
            
            -- 排名
            love.graphics.setFont(love.graphics.newFont(18))
            love.graphics.print(i .. ".", screenWidth * 0.15, y)
            
            -- 名称（限制长度）
            local name = entry.name
            if #name > 20 then
                name = string.sub(name, 1, 18) .. ".."
            end
            love.graphics.print(name, screenWidth * 0.35, y)
            
            -- 分数
            love.graphics.print(entry.score, screenWidth * 0.6, y)
            
            -- 日期
            love.graphics.setFont(love.graphics.newFont(14))
            love.graphics.print(entry.date, screenWidth * 0.75, y + 2)
        end
        
        -- 显示记录总数
        love.graphics.setColor(Utils.colors.textDim)
        love.graphics.setFont(love.graphics.newFont(14))
        text = string.format("Total records: %d", #entries)
        love.graphics.print(text, screenWidth * 0.1, 170 + (#entries + 1) * 35)
    end
    
    -- 底部提示
    love.graphics.setColor(Utils.colors.textDim)
    love.graphics.setFont(love.graphics.newFont(18))
    text = "Press SPACE to play again | ESC to go back"
    textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight - 60)
end

return UI