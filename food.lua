-- food.lua
local Food = {}
Food.__index = Food

function Food:new()
    local food = {
        x = 0,
        y = 0
    }
    setmetatable(food, Food)
    return food
end

function Food:generate(snakeBody)
    local validPosition = false
    local attempts = 0
    local maxAttempts = 1000
    
    while not validPosition and attempts < maxAttempts do
        self.x = math.random(1, Utils.gridWidth)
        self.y = math.random(1, Utils.gridHeight)
        
        validPosition = true
        
        for _, segment in ipairs(snakeBody) do
            if segment.x == self.x and segment.y == self.y then
                validPosition = false
                break
            end
        end
        
        attempts = attempts + 1
    end
end

function Food:getPosition()
    return self.x, self.y
end

function Food:checkEaten(x, y)
    return self.x == x and self.y == y
end

return Food