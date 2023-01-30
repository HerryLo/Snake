-- tile pixel
TILE_SIZE = 32
-- width
WINDOW_WIDTH = 1280
-- height
WINDOW_HEIGHT = 720

GEME_WINDOW_WIDTH = 1080

MAX_TILE_X = GEME_WINDOW_WIDTH/TILE_SIZE
MAX_TILE_Y = math.floor(WINDOW_HEIGHT/TILE_SIZE) - 1

-- tile state 瓦片状态
TILE_EMPTY = 0
TILE_SNAKE_HEAD = 1
TILE_SNAKE_BODY = 2
TILE_APPLE = 3

-- sanke remove speed
SNAKE_SPEED = 0.2

-- font size
local largeFont = love.graphics.newFont(32)

-- init
local tileGird = {}
local snakex, snakey = 1,1
local snakeMoveing = 'right'
local snakeTimer = 0
local score = 0

local snakeTiles = {
    { snakex, snakey }
}

-- load
function love.load()
    love.window.setTitle('Snake 贪吃蛇')

    love.graphics.setFont(largeFont)

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT , {
        fullscreen = false
    })
    initializeGird()

    tileGird[snakeTiles[1][2]][snakeTiles[1][1]] = TILE_SNAKE_HEAD
end

-- keypressed
function love.keypressed(key, unicode)
    -- end
    if key == "escape" then
        love.event.quit()
    end
    -- move
    if key == "left" then
        snakeMoveing = 'left'
    elseif key == "right" then
        snakeMoveing = 'right'
    elseif key == "up" then
        snakeMoveing = 'up'
    elseif key == "down" then
        snakeMoveing = 'down'
    end
end

-- update
function love.update(dt)
    snakeTimer = snakeTimer + dt
    -- print(snakeTimer)

    local priorHeadX, priorHeadY = snakex, snakey
    -- update move
    if snakeTimer >= SNAKE_SPEED then
        if snakeMoveing == 'left' then
            if snakex <= 1 then
                snakex = MAX_TILE_X
            else
                snakex = snakex - 1
            end
        elseif snakeMoveing == 'right' then
            if snakex >= MAX_TILE_X then
                snakex = 1
            else
                snakex = snakex + 1
            end
        elseif snakeMoveing == 'up' then
            if snakey <= 1 then
                snakey = MAX_TILE_Y
            else
                snakey = snakey - 1
            end
        elseif snakeMoveing == 'down' then
            if snakey >= MAX_TILE_Y then
                snakey = 1
            else
                snakey = snakey + 1
            end
        end

        local len = table.maxn(snakeTiles)
        
        -- check for apple and add a score
        if tileGird[snakey][snakex] == TILE_APPLE then
            score = score+1

            -- create a new apple
            createApple()

            -- update snake
            table.insert(snakeTiles, 1, {snakex, snakey})
            tileGird[snakeTiles[1][2]][snakeTiles[1][1]] = TILE_SNAKE_HEAD
        else
            -- update snake
            table.insert(snakeTiles, 1, {snakex, snakey})
            -- remove end snake
            table.remove(snakeTiles, len+1)
        end

        -- update the sname head
        tileGird[snakeTiles[1][2]][snakeTiles[1][1]] = TILE_SNAKE_HEAD

        if #snakeTiles > 1 then 
            tileGird[priorHeadY][priorHeadX] = TILE_SNAKE_BODY
            local tail = snakeTiles[#snakeTiles]
            tileGird[tail[2]][tail[1]] = TILE_EMPTY
        else
            tileGird[priorHeadY][priorHeadX] = TILE_EMPTY
        end

        snakeTimer = 0
    end
end

-- draw
function love.draw()
    -- drawSnake()
    drawgrid()

    drawLine()

    love.graphics.setColor(1,1,1,1)
    love.graphics.print('Score: ' .. tostring(score), GEME_WINDOW_WIDTH, 0)
    -- for i = 1, #snakeTiles  do 
    --     love.graphics.print(snakeTiles[i], 10, 32*i)
    -- end
end

-- draw snake
function drawSnake()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', (snakex - 1) * TILE_SIZE, (snakey - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE )
end

-- draw grid
function drawgrid()
    for y =1, MAX_TILE_Y do
        for x=1, MAX_TILE_X do
            if tileGird[y][x] == TILE_EMPTY then

                -- change the colorto white for grid
                -- love.graphics.setColor(1, 1, 1, 1)
                -- love.graphics.rectangle('line', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)
            elseif tileGird[y][x] == TILE_APPLE then

                -- change the colorto red for apple
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle('fill', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)

            elseif tileGird[y][x] == TILE_SNAKE_HEAD then

                -- change the color red for snake head
                love.graphics.setColor(1, 1, 0.5, 1)
                love.graphics.rectangle('fill', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)

            elseif tileGird[y][x] == TILE_SNAKE_BODY then

                -- change the color red for snake BODY
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.rectangle('fill', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

-- draw table line
function drawLine()
    for x = 1, MAX_TILE_X  do
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.line(TILE_SIZE*x, 0, TILE_SIZE*x, WINDOW_HEIGHT)
    end
    for y = 1, MAX_TILE_Y  do
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.line(0, TILE_SIZE*y, GEME_WINDOW_WIDTH-25, TILE_SIZE*y)
    end
end

-- initialize Gird
function initializeGird()
    for y =1, MAX_TILE_Y do
        
        table.insert(tileGird, {})

        for x=1, MAX_TILE_X do
            table.insert(tileGird[y] , TILE_EMPTY)
            -- print(tileGird[y][x])
        end
    end

    -- init create a apple
    createApple()
end

-- create a apple
function createApple()
    local applex , appley = math.random(MAX_TILE_X),  math.random(MAX_TILE_Y)
    tileGird[appley][applex] = TILE_APPLE
end