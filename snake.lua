-- snake.lua
local Snake = {}
Snake.__index = Snake

function Snake:new()
    local snake = {
        body = {
            {x = 20, y = 15},
            {x = 19, y = 15},
            {x = 18, y = 15}
        },
        direction = "right",
        nextDirection = "right"
    }
    setmetatable(snake, Snake)
    return snake
end

function Snake:updateDirection(newDir)
    -- 防止直接反向
    if (newDir == "right" and self.direction ~= "left") or
       (newDir == "left" and self.direction ~= "right") or
       (newDir == "up" and self.direction ~= "down") or
       (newDir == "down" and self.direction ~= "up") then
        self.nextDirection = newDir
        self.direction = self.nextDirection
        return true
    end
    return false
end

function Snake:getHead()
    return self.body[1]
end

function Snake:getBody()
    return self.body
end

function Snake:getLength()
    return #self.body
end

function Snake:checkSelfCollision()
    local head = self.body[1]
    for i = 2, #self.body do
        if head.x == self.body[i].x and head.y == self.body[i].y then
            return true
        end
    end
    return false
end

function Snake:reset()
    self.body = {
        {x = 20, y = 15},
        {x = 19, y = 15},
        {x = 18, y = 15}
    }
    self.direction = "right"
    self.nextDirection = "right"
end

return Snake