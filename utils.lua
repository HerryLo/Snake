-- utils.lua
Utils = {}

-- 颜色定义
Utils.colors = {
    background = {0.1, 0.1, 0.12},
    snakeBody = {0.2, 0.8, 0.4},
    snakeHead = {1.0, 0.8, 0.2},
    snakeHeadEyes = {0, 0, 0},
    food = {1.0, 0.3, 0.3},
    text = {1, 1, 1},
    textDim = {0.7, 0.7, 0.7},
    grid = {0.2, 0.2, 0.25},
    leaderboard = {0.15, 0.15, 0.2},
    gold = {1, 0.84, 0},
    silver = {0.75, 0.75, 0.75},
    bronze = {0.8, 0.5, 0.2}
}

-- 游戏常量
Utils.gridWidth = 40
Utils.gridHeight = 30
Utils.initialSpeed = 0.25
Utils.maxSpeed = 0.05
Utils.speedIncreasePerPoint = 0.0005

-- 随机名称生成器
Utils.adjectives = {
    "Swift", "Stealthy", "Venomous", "Rainbow", "Shadow", "Neon", "Cyber",
    "Electric", "Wild", "Sneaky", "Mystic", "Cosmic", "Solar", "Lunar",
    "Rapid", "Silent", "Vicious", "Gentle", "Ancient", "Young", "Brave"
}

Utils.nouns = {
    "Python", "Viper", "Cobra", "Boa", "Mamba", "Rattler", "Serpent",
    "Dragon", "Wyrm", "Asp", "Krait", "Adder", "Anaconda", "Sidewinder",
    "Copperhead", "Cottonmouth", "Racer", "Worm"
}

function Utils.generateRandomName()
    local adj = Utils.adjectives[math.random(#Utils.adjectives)]
    local noun = Utils.nouns[math.random(#Utils.nouns)]
    local number = math.random(1, 999)
    return string.format("%s %s #%03d", adj, noun, number)
end

function Utils.calculateSpeed(score)
    local speed = Utils.initialSpeed - (score * Utils.speedIncreasePerPoint)
    return math.max(Utils.maxSpeed, speed)
end

function Utils.isValidPosition(x, y)
    return x >= 1 and x <= Utils.gridWidth and y >= 1 and y <= Utils.gridHeight
end

function Utils.calculateGridOffset()
    local cellSize = math.min(
        love.graphics.getWidth() / Utils.gridWidth,
        love.graphics.getHeight() / Utils.gridHeight
    ) * 0.9
    
    local offsetX = (love.graphics.getWidth() - Utils.gridWidth * cellSize) / 2
    local offsetY = (love.graphics.getHeight() - Utils.gridHeight * cellSize) / 2
    
    return cellSize, offsetX, offsetY
end

return Utils