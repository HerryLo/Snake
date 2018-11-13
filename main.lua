-- tile pixel
TILE_SIZE = 32
-- width
WINDOW_WIDTH = 1280
-- height
WINDOW_HEIGHT = 720

MAX_TILE_X = WINDOW_WIDTH/TILE_SIZE
MAX_TILE_Y = math.floor(WINDOW_HEIGHT/TILE_SIZE) - 1

-- tile state 瓦片状态
TILE_EMPTY = 0
TILE_HEAD = 1
TILE_BODY = 2
TILE_APPLE = 3

-- sanke remove speed
SNAKE_SPEED = 0.5

-- init
local tileGird = {}
local snakex, snakey = 1,1
local snakeMoveing = 'right'
local snakeTimer = 0

-- load
function love.load()
    love.window.setTitle('Snake')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT , {
        fullscreen = false
    })
    initializeGird()
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
    -- update move
    if snakeTimer >= SNAKE_SPEED then
        if snakeMoveing == 'left' then
            snakex = snakex - 1
        elseif snakeMoveing == 'right' then
            snakex = snakex + 1
        elseif snakeMoveing == 'up' then
            snakey = snakey - 1
        elseif snakeMoveing == 'down' then
            snakey = snakey + 1
        end
        snakeTimer = 0
    end
end

-- draw
function love.draw()
    drawSnake()
    drawgrid()
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
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle('line', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)
            elseif tileGird[y][x] == TILE_APPLE then

                -- change the colorto red for apple
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle('fill', (x - 1)*TILE_SIZE, (y - 1) * TILE_SIZE ,TILE_SIZE, TILE_SIZE)
            end
        end
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

    local applex , appley = math.random(MAX_TILE_X),  math.random(MAX_TILE_Y)
    tileGird[appley][applex] = TILE_APPLE
end